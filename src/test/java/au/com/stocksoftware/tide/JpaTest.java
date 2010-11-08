package au.com.stocksoftware.tide;

import au.com.stocksoftware.tide.model.Client;
import au.com.stocksoftware.tide.model.ClientDAO;
import au.com.stocksoftware.tide.model.Employee;
import au.com.stocksoftware.tide.model.EmployeeDAO;
import au.com.stocksoftware.tide.model.SchemaEntityManager;
import au.com.stocksoftware.tide.model.User;
import au.com.stocksoftware.tide.model.UserDAO;
import java.util.Properties;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.testng.Assert.assertTrue;
import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotNull;
import static org.testng.Assert.assertNull;

public class JpaTest
{
  private static final String PERSISTENCE_UNIT_NAME = "tide";
  private static EntityManagerFactory factory;

  @BeforeSuite
  public static void initFactory()
    throws Exception
  {
    final Properties jdbcProperties = new Properties();
    jdbcProperties.load( JpaTest.class.getResourceAsStream( "/database.properties" ) );
    factory = Persistence.createEntityManagerFactory( PERSISTENCE_UNIT_NAME, jdbcProperties );
  }

  @AfterSuite
  public static void shutdownFactory()
    throws Exception
  {
    factory.close();
    factory = null;
  }

  @BeforeMethod
  public void setUp()
    throws Exception
  {
    final EntityManager em = factory.createEntityManager();

    // Begin a new local transaction so that we can persist a new entity
    em.getTransaction().begin();

    // Read the existing entries, should be empty
    final Query q = em.createQuery( "select m from Client m" );

    // Do we have entries?
    boolean createNewEntries = ( q.getResultList().size() == 0 );

    // No, so lets create new entries
    if ( createNewEntries )
    {
      assertTrue( q.getResultList().size() == 0 );
      final Client client = new Client();
      client.setName( "Bob the Builder" );
      em.persist( client );
    }

    // Commit the transaction, which will cause the entity to
    // be stored in the database
    em.getTransaction().commit();

    // It is always good practice to close the EntityManager so that
    // resources are conserved.
    em.close();
  }

  @Test
  public void checkWeHaveBob()
  {
    // Now lets check the database and see if the created entries are there
    // Create a fresh, new EntityManager
    final EntityManager em = factory.createEntityManager();

    // Perform a simple query for all the Message entities
    final TypedQuery<Client> query = em.createQuery( "select c from Client c", Client.class );

    // We should have bob!
    assertTrue( query.getResultList().size() == 1 );
    assertEquals( "Bob the Builder", query.getResultList().get(0).getName() );

    em.close();
  }

  @Test( dependsOnMethods = {"checkWeHaveBob"} )
  public void checkWeHaveFindAll()
  {
    // Now lets check the database and see if the created entries are there
    // Create a fresh, new EntityManager
    final EntityManager em = factory.createEntityManager();

    // Perform a simple query for all the Message entities
    final TypedQuery<Client> query = em.createNamedQuery( "Client.findAll", Client.class );

    // We should have bob!
    assertTrue( query.getResultList().size() == 1 );
    assertEquals( "Bob the Builder", query.getResultList().get(0).getName() );

    em.close();
  }

  @Test(dependsOnMethods = {"checkWeHaveFindAll"})
  public void checkWeHaveFindByID()
  {
    // Now lets check the database and see if the created entries are there
    // Create a fresh, new EntityManager
    final EntityManager em = factory.createEntityManager();

    // get Bob so we can look him up
    final TypedQuery<Client> findAll = em.createNamedQuery( "Client.findAll", Client.class );
    final Client bob = findAll.getResultList().get( 0 );

    final TypedQuery<Client> findByID = em.createNamedQuery( "Client.findByID", Client.class );
    findByID.setParameter( "ID", bob.getID() );

    assertTrue( findByID.getResultList().size() == 1 );
    assertEquals( "Bob the Builder", findByID.getResultList().get(0).getName() );

    em.close();
  }

  @Test(dependsOnMethods = {"checkWeHaveBob"})
  public void testGeneratedDAOs()
  {
    final EntityManager em = factory.createEntityManager();
    SchemaEntityManager.bind( em );
    assertEquals("Bob the Builder", ClientDAO.findByID( ClientDAO.findAll().get( 0 ).getID() ).getName() );
    SchemaEntityManager.unbind( em );
    em.close();
  }

  /*
  @Test(dependsOnMethods = {"checkWeHaveBob"})
  public void testOneToOne()
  {
    final EntityManager em = factory.createEntityManager();
    SchemaEntityManager.bind( em );

    final Employee emp = new Employee();
    emp.setName( "Emp1" );
    emp.setEmail( "fake" );

    // Should be persistable without a User
    em.persist( emp );
    em.getTransaction().commit();
    em.getTransaction().begin();

    System.out.println( "emp:id " + emp.getID() );
    Employee loadedEmp = EmployeeDAO.findByID( emp.getID() );
    assertNotNull( loadedEmp );
    assertNull( loadedEmp.getUser() );

    final User user = new User();
    user.setName( "User1" );
    user.setPassword( "pass" );

    // Should be persistable without an Empl
    em.persist( user );
    em.getTransaction().commit();
    em.getTransaction().begin();
    User loadedUser = UserDAO.findByID( user.getID() );
    assertNotNull( loadedUser );
    assertNull( loadedUser.getEmployee() );

    user.setEmployee( emp );
    em.persist( user );
    em.getTransaction().commit();

    loadedUser = UserDAO.findByID( user.getID() );
    loadedEmp = EmployeeDAO.findByID( emp.getID() );

    assertEquals( loadedEmp, loadedUser.getEmployee() );
    assertEquals( loadedUser, loadedEmp.getUser() );
    assertEquals( user, emp.getUser() );
    
    SchemaEntityManager.unbind( em );
    em.close();
  }
  */
}
