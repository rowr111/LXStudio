// In this file you can define your own custom patterns

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory("Form")
public static class PlanePattern extends LXPattern {
  
  public enum Axis {
    X, Y, Z
  };
  
  public final EnumParameter<Axis> axis =
    new EnumParameter<Axis>("Axis", Axis.X)
    .setDescription("Which axis the plane is drawn across");
  
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position of the center of the plane");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness of the plane");
  
  public PlanePattern(LX lx) {
    super(lx);
    addParameter("axis", this.axis);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }
  
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    float n = 0;
    for (LXPoint p : model.points) {
      switch (this.axis.getEnum()) {
      case X: n = p.xn; break;
      case Y: n = p.yn; break;
      case Z: n = p.zn; break;
      }
      colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos))); 
    }
  }
}

/** ************************************************************** PSYCHEDELIC
 * Colors entire brain in modulatable psychadelic color palettes
 * Demo pattern for GeneratorPalette.
 * @author scouras
 ************************************************************************** */
@LXCategory("Form")
public static class Psychedelic extends LXPattern {
 
  double ms = 0.0;
  double offset = 0.0;
  private final BoundedParameter colorScheme = new BoundedParameter("SCM", 0, 3);
  private final BoundedParameter cycleSpeed = new BoundedParameter("SPD",  10, 0, 200);
  private final BoundedParameter colorSpread = new BoundedParameter("LEN", 5, 2, 1000);
  private final BoundedParameter colorHue = new BoundedParameter("HUE",  0., 0., 359.);
  private final BoundedParameter colorSat = new BoundedParameter("SAT", 80., 0., 100.);
  private final BoundedParameter colorBrt = new BoundedParameter("BRT", 50., 0., 100.);
  private GeneratorPalette gp = 
      new GeneratorPalette(
          new ColorOffset(0xDD0000).setHue(colorHue)
                                   .setSaturation(colorSat)
                                   .setBrightness(colorBrt),
          //GeneratorPalette.ColorScheme.Complementary,
          GeneratorPalette.ColorScheme.Monochromatic,
          //GeneratorPalette.ColorScheme.Triad,
          //GeneratorPalette.ColorScheme.Analogous,
          100
      );
  private int scheme = 0;
  //private EvolutionUC16 EV = EvolutionUC16.getEvolution(lx);

  public Psychedelic(LX lx) {
    super(lx);
    addParameter(colorScheme);
    addParameter(cycleSpeed);
    addParameter(colorSpread);
    addParameter(colorHue);
    addParameter(colorSat);
    addParameter(colorBrt);
    /*println("Did we find an EV? ");
    println(EV);
    EV.bindKnob(colorHue, 0);
    EV.bindKnob(colorSat, 8);
    EV.bindKnob(colorBrt, 7);
    */
  }
    
    public void run(double deltaMs) {
    int newScheme = (int)Math.floor(colorScheme.getValue());
    if ( newScheme != scheme) { 
      switch(newScheme) { 
        case 0: gp.setScheme(GeneratorPalette.ColorScheme.Analogous); break;
        case 1: gp.setScheme(GeneratorPalette.ColorScheme.Monochromatic); break;
        case 2: gp.setScheme(GeneratorPalette.ColorScheme.Triad); break;
        case 3: gp.setScheme(GeneratorPalette.ColorScheme.Complementary); break;
        }
      scheme = newScheme;
      }

    ms += deltaMs;
    offset += deltaMs*cycleSpeed.getValue()/1000.;
    int steps = (int)colorSpread.getValue();
    if (steps != gp.steps) { 
      gp.setSteps(steps);
    }
    gp.reset((int)offset);
    for (LXPoint p : model.points) {
      colors[p.index] = gp.getColor();
    }
  }
}

/** ****************************************************** RAINBOW BARREL ROLL
 * A colored plane of light rotates around an axis
 ************************************************************************* **/
 @LXCategory("Form")
public static class RainbowRoll extends LXPattern {
   float hoo;
   
   public final CompoundParameter angle = new CompoundParameter("Angle", 180, 0, 360)
    .setDescription("barrel roll angle");
    
  public RainbowRoll(LX lx){
     super(lx);   
     addParameter("Angle", this.angle);
  }
  
 public void run(double deltaMs) {
     //anglemod=anglemod+1;
     //if (anglemod > 360){
       //anglemod = anglemod % 360;
     //}
     
    for (LXPoint p: model.points) {
      //conveniently, hue is on a scale of 0-360
      hoo=((atan(p.x/p.z))*360/PI+this.angle.getValuef());
      colors[p.index]=lx.hsb(hoo,80,50);
    }
  }
}


//fucking around testing audio stuff
@LXCategory("Form")
public class MusicTester extends LXPattern {
  //private GraphicEQ eq = null;
  //List<List<LXPoint>> strips_emanating_from_nodes = new ArrayList<List<LXPoint>>();
  private LXAudioEngine audioEngine = new LXAudioEngine(lx);
  private LXAudioInput audioInput = audioEngine.getInput();

  private DecibelMeter dbMeter = audioEngine.meter;
 
  public MusicTester(LX lx) {
    super(lx);
      //addModulator(dbMeter).start();
  }
  
  public void run(double deltaMs) {
    
    //float bassLevel = audioInput.mix.level();//eq.getAveragef(0, 5) * 5000;
    float soundLevel = -dbMeter.getDecibelsf()*0.5;
    println(lx.tempo.bpm());
    float myTempo = (float)lx.tempo.bpm();
    for (LXPoint p: model.points) {
      colors[p.index] = lx.hsb(random(100,120),40,40);
       float hoo = 300- 2500/myTempo;
        float saturat = 100;
        float britness = max(0, 100 - 2500/myTempo);
       addColor(p.index, lx.hsb(hoo, saturat, britness));
    }
   }
}
