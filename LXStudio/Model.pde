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
  public final static int SIZE = 49;

  
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

/******************************************************************************/
/* Image mapping                                                              */
/******************************************************************************/


/**
 * Class for mapping images onto the brain.
 * Operates by doing all the math for which pixels in the image map to which pixels on the brain, once
 * Then shifts things around by changing the pixels in the image.
 * TODO: Could use some optimization magic. Does unkind things to the framerate.
 * @param imagecolors is a Processing PImage which stores the image
 * @param cartesian_canvas defines what coordinate system the image gets mapped to
 * @param imagedims is the dimensions of the image in pixels
 * @param compress_pct compresses the image by a certain percent to improve performance.  Will vary by image and machine.
*/ 
public class MentalImage {

  PImage imagecolors;
  String cartesian_canvas;
  int w;
  int h;
  
  SortedMap<Integer, int[]> pixel_to_pixel = new TreeMap<Integer, int[]>();
  SortedMap<Integer, float[]> led_colors = new TreeMap<Integer, float[]>();

  //Constructor for class
  public MentalImage(String imagepath, String cartesian_canvas, int compress_pct){
      this.imagecolors = loadImage(imagepath);
      loadPixels();
      this.imagecolors.resize(this.imagecolors.width*compress_pct/100,0);
      this.cartesian_canvas=cartesian_canvas;
      this.imagecolors.loadPixels();
      this.w=imagecolors.width;
      this.h=imagecolors.height;
      //Map the points in the image to the model, once.
      for (LXPoint p : lx.model.points) {
        int[] point_loc_in_img=scaleLocationInImageToLocationInBrain(p);
        this.pixel_to_pixel.put(p.index,point_loc_in_img);
      }
  }
  
  //Constructor for class
  public MentalImage(PImage inputImage, String cartesian_canvas, int compress_pct){
      this.imagecolors = inputImage;
      loadPixels();
      this.imagecolors.resize(this.imagecolors.width*compress_pct/100,0);
      this.cartesian_canvas=cartesian_canvas;
      this.imagecolors.loadPixels();
      this.w=imagecolors.width;
      this.h=imagecolors.height;
      //Map the points in the image to the model, once.
      for (LXPoint p : lx.model.points) {
        int[] point_loc_in_img=scaleLocationInImageToLocationInBrain(p);
        this.pixel_to_pixel.put(p.index,point_loc_in_img);
      }
  }

  public void updateImage(PImage newImage, String cartesian_canvas, int compress_pct)
  {
    this.imagecolors = newImage;
      loadPixels();
      this.imagecolors.resize(this.imagecolors.width*compress_pct/100,0);
      this.cartesian_canvas=cartesian_canvas;
      this.imagecolors.loadPixels();
      this.w=imagecolors.width;
      this.h=imagecolors.height;
      //Map the points in the image to the model, once.
      for (LXPoint p : lx.model.points) {
        int[] point_loc_in_img=scaleLocationInImageToLocationInBrain(p);
        this.pixel_to_pixel.put(p.index,point_loc_in_img);
      }
  }
  /**
  * Outputs one frame of the image in its' current state to the pixel mapping.
  * @param colors: The master colors array
  */
  public int[] ImageToPixels(int[] colors){
    color pixelcolor;
    float[] hsb_that_pixel;
    int[] loc_in_img;
    for (LXPoint p : lx.model.points) {
      loc_in_img = scaleLocationInImageToLocationInBrain(p);
      pixelcolor = this.imagecolors.get(loc_in_img[0],loc_in_img[1]);
      colors[p.index]= lx.hsb(hue(pixelcolor),saturation(pixelcolor),brightness(pixelcolor));
    }
    return colors;
  }


  /**
  * Outputs one frame of the image in its' current state to the pixel mapping.
  * Current preferred method for using moving images. Faster than translating the image under the mapping.
  * @param colors: The master colors array
  */
  public int[] shiftedImageToPixels(int[] colors, float xpctshift,float ypctshift){
    int[] colors2 = shiftedImageToPixels(colors, xpctshift, ypctshift, 1.0);
    return colors2;
  }
  public int[] shiftedImageToPixels(int[] colors, float xpctshift,float ypctshift, float scale){
    color pixelcolor;
    float[] hsb_that_pixel;
    int[] loc_in_img;
    for (LXPoint p : lx.model.points) {
      loc_in_img = scaleShiftedScaledLocationInImageToLocationInBrain(p,xpctshift,ypctshift,scale);
      pixelcolor = this.imagecolors.get(loc_in_img[0],loc_in_img[1]);
      colors[p.index]= lx.hsb(hue(pixelcolor),saturation(pixelcolor),brightness(pixelcolor));
    }
    return colors;
  }




  /**
  * Translates the image in either the x or y axis. 
  * Important to note that this is operating on the image itself, not on the pixel mapping, so it's just x and y
  * This seems to get worse performance than just recalculating the LED pixels across different positions in the image if looped.
  * Automatically wraps around.
  * @param which_axis: x or y or throw exception
  * @param pctrate: How much percentage of the image to translate?
  */
  public void translate_image(String which_axis, float pctrate) { //String which_axis, float percent, boolean wrap
    PImage translate_buffer;
    if (which_axis.equals("x")) {
      translate_buffer=imagecolors; 
      int rate = int(imagecolors.width*(pctrate/100.0));
      for (int imgy = 0; imgy < imagecolors.height; imgy++) {
        for (int inc = 1; inc < rate+1; inc++) {
          imagecolors.set(imagecolors.width-inc,imgy,translate_buffer.get(0,imgy));
        }
      }
  
      for (int imgx = 0; imgx < imagecolors.width-rate; imgx++ ) {
        for (int imgy = 0; imgy < imagecolors.height; imgy++) {
          imagecolors.set(imgx,imgy,translate_buffer.get(imgx+rate,imgy));
        }
      }
    } else if (which_axis.equals("y")){
      translate_buffer=imagecolors; 
      int rate = int(imagecolors.height*(pctrate/100.0));
      for (int imgx = 0; imgx < imagecolors.width; imgx++) {
        for (int inc = 1; inc < rate+1; inc++) {
          imagecolors.set(imgx,imagecolors.height-inc,translate_buffer.get(imgx,0));
        }
      }
  
      for (int imgy = 0; imgy < imagecolors.height-rate; imgy++ ) {
        for (int imgx = 0; imgx < imagecolors.width; imgx++) {
          imagecolors.set(imgx,imgy,translate_buffer.get(imgx,imgy+rate));
        }
      }
    } else{
      throw new IllegalArgumentException("Axis must be x or y. Image axis, not model axis :)");
    }
  }

  /**
  * Returns the coordinates for an LXPoint p (which has x,y,z) that correspond to a location on an image based on the coordinate system 
  * @param p: The LXPoint to get coordinates for.
  */
  private int[] scaleLocationInImageToLocationInBrain(LXPoint p) {
    float[][] minmaxxy;
    float newx;
    float newy;
    if (this.cartesian_canvas.equals("xy")){
      minmaxxy=new float[][]{{lx.model.xMin,lx.model.xMax},{lx.model.yMin,lx.model.yMax}};
      newx=(1-(p.x-minmaxxy[0][0])/(minmaxxy[0][1]-minmaxxy[0][0]))*this.w;
      newy=(1-(p.y-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))*this.h;
    }
    else if (this.cartesian_canvas.equals("xz")){
      minmaxxy=new float[][]{{lx.model.xMin,lx.model.xMax},{lx.model.zMin,lx.model.zMax}};
      newx=(1-(p.x-minmaxxy[0][0])/(minmaxxy[0][1]-minmaxxy[0][0]))*this.w;
      newy=(1-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))*this.h;
    }
    else if (this.cartesian_canvas.equals("yz")){
      minmaxxy=new float[][]{{lx.model.yMin,lx.model.yMax},{lx.model.zMin,lx.model.zMax}};
      newx=(1-(p.y-minmaxxy[0][0])/(minmaxxy[0][1]-minmaxxy[0][0]))*this.w;
      newy=(1-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))*this.h;
    }
    else if (this.cartesian_canvas.equals("cylindrical_x")){
      minmaxxy=new float[][]{{lx.model.xMin,lx.model.xMax},{lx.model.xMin,lx.model.xMax}};
      newx=(1-((atan2(p.z,p.y)+PI)/(2*PI)))*this.w;
      newy=(1-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))*this.h;
    }
    else if (this.cartesian_canvas.equals("cylindrical_y")){
      minmaxxy=new float[][]{{lx.model.yMin,lx.model.yMax},{lx.model.yMin,lx.model.yMax}};
      newx=(1-((atan2(p.z,p.x)+PI)/(2*PI)))*this.w;
      newy=(1-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))*this.h;
    }
    else if (this.cartesian_canvas.equals("cylindrical_z")){
      minmaxxy=new float[][]{{lx.model.zMin,lx.model.zMax},{lx.model.zMin,lx.model.zMax}};
      newx=(1-((atan2(p.y,p.x)+PI)/(2*PI)))*this.w;
      newy=(1-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))*this.h;
    }
    else{
      throw new IllegalArgumentException("Must enter plane xy, xz, yz, or cylindrical_x/y/z");
    }
      int newxint=(int)newx;
      int newyint=(int)newy;
      if (newxint>=this.w){
         newxint=newxint-1;
      }
      if (newxint<=0){
         newxint=newxint+1;
      }
      if (newyint>=this.h){
         newyint=newyint-1;
      }
      if (newyint<=0){
         newyint=newyint+1;
      }
      int[] result = new int[] {newxint,newyint};
      return result;
  }





  /**
  * Returns the SHIFTED coordinates for an LXPoint p (which has x,y,z) that correspond to a location on an image based on the coordinate system 
  * This seems to get better performance in the run loop than using translate on the image repetitively.
  * @param p: The LXPoint to get coordinates for.
  * @param xpctshift: How far to move the image in the x direction, as a percent of the image width
  * @param ypctshift: How far to move the image in the y direction, as a percent of the image height
  */
  private int[] scaleShiftedLocationInImageToLocationInBrain(LXPoint p, float xpctshift, float ypctshift){
    int[] result = scaleShiftedScaledLocationInImageToLocationInBrain(p, xpctshift, ypctshift, 1.0);
    return result;
  }
  
  private int[] scaleShiftedScaledLocationInImageToLocationInBrain(LXPoint p, float xpctshift, float ypctshift, float scale) {
    float[][] minmaxxy;
    float newx;
    float newy;
    if (this.cartesian_canvas.equals("xy")){
      minmaxxy=new float[][]{{lx.model.xMin,lx.model.xMax},{lx.model.yMin,lx.model.yMax}};
      newx=(1+xpctshift-(p.x-minmaxxy[0][0])/(minmaxxy[0][1]-minmaxxy[0][0]))%1.0*this.w*scale;
      newy=(1+ypctshift-(p.y-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))%1.0*this.h*scale;
    }
    else if (this.cartesian_canvas.equals("xz")){
      minmaxxy=new float[][]{{lx.model.xMin,lx.model.xMax},{lx.model.zMin,lx.model.zMax}};
      newx=(1+xpctshift-(p.x-minmaxxy[0][0])/(minmaxxy[0][1]-minmaxxy[0][0]))%1.0*this.w*scale;
      newy=(1+ypctshift-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))%1.0*this.h*scale;
    }
    else if (this.cartesian_canvas.equals("yz")){
      minmaxxy=new float[][]{{lx.model.yMin,lx.model.yMax},{lx.model.zMin,lx.model.zMax}};
      newx=(1+xpctshift-(p.y-minmaxxy[0][0])/(minmaxxy[0][1]-minmaxxy[0][0]))%1.0*this.w*scale;
      newy=(1+ypctshift-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))%1.0*this.h*scale;
    }
    else if (this.cartesian_canvas.equals("cylindrical_x")){
      minmaxxy=new float[][]{{lx.model.xMin,lx.model.xMax},{lx.model.xMin,lx.model.xMax}};
      newx=(1+xpctshift-((atan2(p.z,p.y)+PI)/(2*PI)))%1.0*this.w*scale;
      newy=(1+ypctshift-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))%1.0*this.h*scale;
    }
    else if (this.cartesian_canvas.equals("cylindrical_y")){
      minmaxxy=new float[][]{{lx.model.yMin,lx.model.yMax},{lx.model.yMin,lx.model.yMax}};
      newx=(1+xpctshift-((atan2(p.z,p.x)+PI)/(2*PI)))%1.0*this.w*scale;
      newy=(1+ypctshift-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))%1.0*this.h*scale;
    }
    else if (this.cartesian_canvas.equals("cylindrical_z")){
      minmaxxy=new float[][]{{lx.model.zMin,lx.model.zMax},{lx.model.zMin,lx.model.zMax}};
      newx=(1+xpctshift-((atan2(p.y,p.x)+PI)/(2*PI)))%1.0*this.w*scale;
      newy=(1+ypctshift-(p.z-minmaxxy[1][0])/(minmaxxy[1][1]-minmaxxy[1][0]))%1.0*this.h*scale;
    }
    else{
      throw new IllegalArgumentException("Must enter plane xy, xz, yz, or cylindrical_x/y/z");
    }
      int newxint=int((newx % this.w+this.w)%this.w);
      int newyint=int((newy % this.h+this.h)%this.h);
      int[] result = new int[] {newxint,newyint};
      return result;
  }
}
