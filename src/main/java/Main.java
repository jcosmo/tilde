import Core.Client;
import Core.ClientDAO;
import Core.SchemaEntityManager;
import java.io.IOException;
import java.util.Properties;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public class Main
{
  public static void main( final String[] args )
    throws IOException
  {
    final Properties jdbcProperties = new Properties();
    jdbcProperties.load( Main.class.getResourceAsStream( "database.properties" ) );
    final EntityManagerFactory emf = Persistence.createEntityManagerFactory( "tide", jdbcProperties );

    final EntityManager em = emf.createEntityManager();
    SchemaEntityManager.bind( em );

    for ( Client client : ClientDAO.findAll() )
    {
      System.out.println( "Found a client: " + client.getName() );
    }
  }
}