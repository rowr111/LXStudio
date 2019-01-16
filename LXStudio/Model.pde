LXModel buildModel() {
  // A three-dimensional grid model
  return new GridModel3D();
}

public static class GridModel3D extends LXModel {
  
  public final static int SIZE = 39;
  
  public GridModel3D() {
    super(new Fixture());
  }
  
  public static class Fixture extends LXAbstractFixture {
    Fixture() {
      for (int z = 0; z <= SIZE; ++z) {
        for (int y = 0; y <= SIZE; ++y) {
          for (int x = 0; x <= SIZE; ++x) {
            if (((x==0)|(y==0)|(z==0))|((x==SIZE)|(y==SIZE)|(z==SIZE)))
               addPoint(new LXPoint(x, y, z));
          }
        }
      }
    }
  }
}
