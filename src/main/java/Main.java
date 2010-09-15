import Core.Client;
import Core.ClientDAO;
import Core.SchemaEntityManager;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.TypedQuery;

public class Main
{
  public static void main( final String[] args )
  {
    final Map<String, Object> overrides = new HashMap<String, Object>();
    overrides.put( "javax.persistence.provider", "org.apache.openjpa.persistence.PersistenceProviderImpl" );
    overrides.put( "javax.persistence.jdbc.driver", "net.sourceforge.jtds.jdbc.Driver" );
    overrides.put( "javax.persistence.jdbc.user", "sa" );
    overrides.put( "javax.persistence.jdbc.password", "password" );
    overrides.put( "javax.persistence.jdbc.url",
                   "jdbc:jtds:sqlserver://localhost/tide_dev;instance=sqlexpress" );

    final EntityManagerFactory emf =
      Persistence.createEntityManagerFactory( "tide", overrides );

    final EntityManager em = emf.createEntityManager();
    SchemaEntityManager.bind( em );

    for ( Client client : ClientDAO.findAll() )
    {
      System.out.println( "Found a client: " + client.getName() );
    }
  }
}