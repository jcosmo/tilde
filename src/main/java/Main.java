import core.Clients;
import core.ClientsDAO;
import core.SchemaEntityManager;
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
    overrides.put( "javax.persistence.jdbc.user", "stock-dev" );
    overrides.put( "javax.persistence.jdbc.password", "letmein" );
    overrides.put( "javax.persistence.jdbc.url",
                   "jdbc:jtds:sqlserver://vw-firesql-104.fire.dse.vic.gov.au/JW45_TILDE_DEV;appName=iris_app;instance=mssql01" );

    final EntityManagerFactory emf =
      Persistence.createEntityManagerFactory( "tide", overrides );

    final EntityManager em = emf.createEntityManager();
    SchemaEntityManager.bind( em );

    for ( Clients client : ClientsDAO.findAll() )
    {
      System.out.println( "Found a client: " + client.getName() );
    }
  }
}