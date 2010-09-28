package jpa_osgi;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.testng.Assert.assertTrue;

public class JpaTest
{
  private static final String PERSISTENCE_UNIT_NAME = "people";
  private static EntityManagerFactory factory;

  @BeforeSuite
  public static void initFactory()
    throws Exception
  {
    factory = Persistence.createEntityManagerFactory( PERSISTENCE_UNIT_NAME );
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

    // Read the existing entries
    final Query q = em.createQuery( "select m from Person m" );
    // Persons should be empty

    // Do we have entries?
    boolean createNewEntries = ( q.getResultList().size() == 0 );

    // No, so lets create new entries
    if ( createNewEntries )
    {
      assertTrue( q.getResultList().size() == 0 );
      final Family family = new Family();
      family.setDescription( "Family for the Knopfs" );
      em.persist( family );
      for ( int i = 0; i < 40; i++ )
      {
        final Person person = new Person();
        person.setFirstName( "Jim_" + i );
        person.setLastName( "Knopf_" + i );
        em.persist( person );
        // First we have to persists the job
        // Now persists the new person
        family.getMembers().add( person );
        em.persist( person );
        em.persist( family );
      }
    }

    // Commit the transaction, which will cause the entity to
    // be stored in the database
    em.getTransaction().commit();

    // It is always good practice to close the EntityManager so that
    // resources are conserved.
    em.close();

  }

  @Test
  public void checkAvailablePeople()
  {

    // Now lets check the database and see if the created entries are there
    // Create a fresh, new EntityManager
    EntityManager em = factory.createEntityManager();

    // Perform a simple query for all the Message entities
    Query q = em.createQuery( "select m from Person m" );

    // We should have 40 Persons in the database
    assertTrue( q.getResultList().size() == 40 );

    em.close();
  }

  @Test
  public void checkFamily()
  {
    final EntityManager em = factory.createEntityManager();
    // Go through each of the entities and print out each of their
    // messages, as well as the date on which it was created
    final Query q = em.createQuery( "select f from Family f" );

    // We should have one family with 40 persons
    assertTrue( q.getResultList().size() == 1 );
    assertTrue( ( (Family) q.getSingleResult() ).getMembers().size() == 40 );
    em.close();
  }

  @Test( expectedExceptions = javax.persistence.NoResultException.class )
  public void deletePerson()
  {
    final EntityManager em = factory.createEntityManager();
    // Begin a new local transaction so that we can persist a new entity
    em.getTransaction().begin();
    final Query q =
      em.createQuery( "SELECT p FROM Person p WHERE p.firstName = :firstName AND p.lastName = :lastName" );
    q.setParameter( "firstName", "Jim_1" );
    q.setParameter( "lastName", "Knopf_!" );
    final Person user = (Person) q.getSingleResult();
    em.remove( user );
    em.getTransaction().commit();
    Person person = (Person) q.getSingleResult();
    // Begin a new local transaction so that we can persist a new entity

    em.close();
  }
}
