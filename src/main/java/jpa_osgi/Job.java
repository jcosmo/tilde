package jpa_osgi;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

@Entity
public class Job
{
  @Id
  @GeneratedValue( strategy = GenerationType.TABLE )
  private int id;
  private double salary;
  private String jobDescription;

  public int getId()
  {
    return id;
  }

  public void setId( int id )
  {
    this.id = id;
  }

  public double getSalary()
  {
    return salary;
  }

  public void setSalary( final double salary )
  {
    this.salary = salary;
  }

  public String getJobDescription()
  {
    return jobDescription;
  }

  public void setJobDescription( final String jobDescription )
  {
    this.jobDescription = jobDescription;
  }

}