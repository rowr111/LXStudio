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
