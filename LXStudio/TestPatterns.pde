///////////////////////////////////////////////////////////
//                 TEST PATTERNS                         //
///////////////////////////////////////////////////////////
// a place to try out functionality and create basic patterns
// add @LXCategory("Test") above all methods


//adjustable hue, saturation, and brightness.
@LXCategory("Test")
public class TestHueSatBright extends LXPattern {
   public final CompoundParameter hue = new CompoundParameter("Hue", 180, 0, 360)
    .setDescription("color hue"); 
  
  public final CompoundParameter sat = new CompoundParameter("Sat", 80, 0, 100)
    .setDescription("color saturation");
  
  public final CompoundParameter brt = new CompoundParameter("Bright", 80, 0, 100)
    .setDescription("brightness level");
  
  public TestHueSatBright(LX lx) {
    super(lx);
    addParameter("Hue", this.hue);
    addParameter("Sat", this.sat);
    addParameter("Bright", this.brt);
  }
  
   public void run(double deltaMs) {    
    for (LXPoint p: model.points) {
      //hue is on a scale of 0-360
      //saturation is on a scale of 0-100
      //brightness is on a scale of 0-100
      colors[p.index]=lx.hsb(this.hue.getValuef(), this.sat.getValuef(), this.brt.getValuef());
    }
  }
}

//each face has a different color, iterating
//todo: this pattern is currently borked, fix it
@LXCategory("Test")
public class TestFaceIterator extends LXPattern {
   public final CompoundParameter delay = new CompoundParameter("delaytime", 100, 1, 2000)
    .setDescription("ms between iterations"); 
    

    
   public TestFaceIterator(LX lx) {
    super(lx);
    addParameter("delaytime", this.delay);
  }
  
  int hue = 0;
  
  public void run(double deltaMs) {
    //this.timer.wait((long)this.delay.getValue());
    List<List<LXPoint>> faces = new ArrayList<List<LXPoint>>();
    faces.add(XY0); faces.add(XY1); faces.add(YZ0); faces.add(YZ1); faces.add(XZ0); faces.add(XZ1);

    for (List<LXPoint> face: faces) {
      
       hue += 1;
       if (hue > 360)
         hue = hue % 360;
       for (LXPoint p: face)
         colors[p.index]=lx.hsb(hue, 100, 80);
    }
  
  }

}

@LXCategory("Test")
public class TestImage extends LXPattern {
  MentalImage mentalimage = new MentalImage("media/images/stormclouds_purple.jpg","xy",100);  
  
  public TestImage(LX lx){
     super(lx);  
  }
 public void run(double deltaMs) {                    
   colors=this.mentalimage.shiftedImageToPixels(colors,0,0);
  } 
}
