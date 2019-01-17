public class PatternAudioMeter extends LXPattern {
  public String getAuthor() {
    return "Mark C. Slee + some mods by Jeanie";
  }
  
  //todo: clean all this up when you figure out what you actually want to do with this pattern.. 
  
  private final CompoundParameter colorChangeSpeed = new CompoundParameter("SPD",  5000, 0, 10000);
  private final SinLFO whatColor = new SinLFO(0, 1, colorChangeSpeed);
  private float basis = 0;

  
  public final CompoundParameter mode =
    new CompoundParameter("Mode", 0)
    .setDescription("Sets the mode of the equalizer");
    
  public final CompoundParameter size =
    new CompoundParameter("Size", .2, .1, .4)
    .setDescription("Sets the size of the display");
  
  public PatternAudioMeter(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
    addParameter("size", this.size);
    addParameter(colorChangeSpeed);
    addModulator(whatColor).trigger();

  }
  
  public void run(double deltaMs) {
    //this.basis = (float) (this.basis + .001 * colorChangeSpeed.getValuef() * deltaMs) % TWO_PI;
    this.basis = (float) (this.basis + .001 * deltaMs) % TWO_PI;
    float meter = lx.engine.audio.meter.getValuef();
    float mode = this.mode.getValuef();
    float falloff = 100 / this.size.getValuef();
    for (LXPoint p : model.points) {
      float pPos = 2 * abs(p.yn - .5);
      //float pPos = p.yn;
      float b1 = constrain(50 - falloff * (pPos - meter), 0, 100);
      float b2 = constrain(50 - falloff * abs(pPos - meter), 0, 100);
      float bright = lerp(b1, b2, mode);
      //float hue = 2*abs(p.yn-.5)*360;
      //float hue = sin(p.yn)*360;
      //float hue = whatColor.getValuef()*180;
      //float hue = ((atan(p.x/p.z))*360/PI)*whatColor.getValuef();
      float hue = (this.basis + p.azimuth * (1 - p.yn)) / TWO_PI * 360;
      //float hue = (this.basis + p.azimuth * (2*abs(p.zn-.5))) / TWO_PI * 360;
      setColor(p.index, lx.hsb(hue, 100, bright));
    }
  } 
}
