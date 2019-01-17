import java.util.*;

LXModel buildModel() {
  // A three-dimensional grid model
  return new GridModel3D();
}

//lists of all the points on each face
public static List<LXPoint> XY0 = new ArrayList<LXPoint>();
public static List<LXPoint> XY1 = new ArrayList<LXPoint>();
public static List<LXPoint> YZ0 = new ArrayList<LXPoint>();
public static List<LXPoint> YZ1 = new ArrayList<LXPoint>();
public static List<LXPoint> XZ0 = new ArrayList<LXPoint>();
public static List<LXPoint> XZ1 = new ArrayList<LXPoint>();

public static class GridModel3D extends LXModel {
  
  //this value is the final size - 1
  public final static int SIZE = 24;

  
  public GridModel3D() {
    super(new Fixture());
  }
  
  public static class Fixture extends LXAbstractFixture {
    
    Fixture() {
      for (int z = 0; z <= SIZE; ++z) {
        for (int y = 0; y <= SIZE; ++y) {
          for (int x = 0; x <= SIZE; ++x) {
            if (((x==0)|(y==0)|(z==0))|((x==SIZE)|(y==SIZE)|(z==SIZE)))
              {
                LXPoint p = new LXPoint(x,y,z);
               addPoint(p);
               
               if(z==0)
                 XY0.add(p);
               if(z==SIZE)
                 XY1.add(p);
               if(x==0)
                 YZ0.add(p);
               if(x==SIZE)
                 YZ1.add(p);
               if(y==0)
                 XZ0.add(p);
               if(y==SIZE)
                 XZ1.add(p);
              }
          }
        }
      }
    }
  }
}
