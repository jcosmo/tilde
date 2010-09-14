import core.Clients;
import java.util.List;
import javax.persistence.*;

public class Main
{
  public static void main( final String []args )
  {
    final EntityManagerFactory entityManagerFactory = Persistence.createEntityManagerFactory( "main" );
    final EntityManager entityManager = entityManagerFactory.createEntityManager();
    final TypedQuery<Clients> namedQuery = entityManager.createNamedQuery( "Clients.findAll", Clients.class );
    final List<Clients> resultList = namedQuery.getResultList();
    for ( Clients client : resultList )
    {
      System.out.println( "Found a client: " + client.getName() );
    }
  }
}