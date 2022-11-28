public class Sprite{
  PImage img;
  float x, y, center_x, center_y, change_x, change_y, w, h ;
  
  public Sprite(String file, float scale, float x, float y){
    img = loadImage(file);
    w = img.width *scale;
     h = img.height *scale;
    center_x = x;
    center_y = y;
    change_x = 0;
    change_y = 0;
  }
  
  public Sprite(String file, float scale){
    this(file, scale, 0, 0);
  }
  
  public Sprite(PImage image, float scale){
    img = image;
    w = img.width *scale;
    h = img.height*scale;
    center_x = 0;
    center_y = 0;
    change_x = 0;
    change_y = 0;
    
  }
  public void display(){
    image(img, center_x, center_y, w, h);
  }
  
  public void update(){
    center_x +=change_x;
    center_y +=change_y;
  } 
  
  public void setLeft(float newLeft){
    center_x = newLeft + w/2;
  }
  public void setRight(float newRight){
    center_x = newRight - w/2;
  }
  public void setTop(float newTop){
    center_y = newTop + h/2;
  }
  public void setBottom(float newBottom){
    center_y = newBottom - h/2;
  } 
  
  float getLeft(){
    return center_x - w/2;
  }
  float getRight(){
    return center_x + w/2;
  }
  float getTop(){
    return center_y - h/2;
  }
  float getBottom(){
    return center_y + h/2;
  }
  
  
}
