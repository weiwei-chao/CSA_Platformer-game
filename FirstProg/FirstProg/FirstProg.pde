final static float MOVE_SPEED = 5;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50; 
final static float GRAVITY = 0.6; 
final static float JUMP_SPEED = 14; 

final static float RIGHT_MARGIN = 400; 
final static float LEFT_MARGIN = 60; 
final static float VERTICAL_MARGIN = 40; 

final static int NEUTRAL_FACING = 0; 
final static int RIGHT_FACING = 1; 
final static int LEFT_FACING = 2; 
final static int DEAD = 3; 

final static float WIDTH = SPRITE_SIZE * 16; 
final static float HEIGHT = SPRITE_SIZE * 12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE; 

Player p;  
PImage snow, crate, red_brick, brown_brick, gold, spider, player; 
ArrayList<Sprite> platforms; 
ArrayList<Sprite> coins; 
Enemy enemy; 

boolean isGameOver;
int numCoins; 
float view_x; 
float view_y; 
int levelNum;
int temp=0; 
 
void setup() {
  size(800, 600); 
  imageMode(CENTER);
  PImage player = loadImage("player.png");
  p = new Player(player, 0.8); 
  p.center_x = 100; 
  p.change_y = GROUND_LEVEL; 
  
  platforms = new ArrayList<Sprite>(); 
  coins = new ArrayList<Sprite>(); 
  numCoins = 0; 
  isGameOver = false;
  levelNum = 1;
  
  gold = loadImage("gold1.png");
  spider = loadImage("spider_walk_right1.png"); 
  red_brick = loadImage("red_brick.png");
  brown_brick = loadImage("brown_brick.png");
  crate = loadImage("crate.png");
  snow = loadImage("snow.png");
    
  createPlatforms("map.csv"); 
    
  view_x = 0; 
  view_y = 0;
  //println(enemy==null);
}

void setup2() {
  size(800, 600); 
  imageMode(CENTER);
  PImage player = loadImage("player.png");
  p = new Player(player, 0.8); 
  p.center_x = 100; 
  p.change_y = GROUND_LEVEL; 
  
  platforms = new ArrayList<Sprite>(); 
  coins = new ArrayList<Sprite>(); 
  numCoins = 10; 
  isGameOver = false;
  levelNum = 2; 
  p.lives = temp; 
   
  gold = loadImage("gold1.png");
  spider = loadImage("spider_walk_right1.png"); 
  red_brick = loadImage("red_brick.png");
  brown_brick = loadImage("brown_brick.png");
  crate = loadImage("crate.png");
  snow = loadImage("snow.png");
    
  createPlatforms("map2.csv"); 
    
  view_x = 0; 
  view_y = 0;
  //println(enemy==null);
  
}

void draw() {
  background(255);
  scroll();
  displayAll();
  
  if(!isGameOver){
    updateAll(); 
    collectCoins(); 
    checkDeath(); 
  }
}

void displayAll(){
  p.display();
  for(Sprite s: platforms)
    s.display(); 
  for(Sprite c: coins){
    c.display(); 
  }
  collectCoins(); 
  fill(255, 0, 0); 
  textSize(32); 
  text("Coin:" + numCoins, view_x + 50, view_y + 50); 
  text("Lives:" + p.lives, view_x + 50, view_y + 100); 
  text("Level:" + levelNum, view_x + 50, view_y + 150);
  
  enemy.display(); 
  enemy.update(); 
  
  if(isGameOver){
    fill(0,0,255);
    text("GAME OVER:", view_x + width/2 - 100, view_y + height/2 - 150); 
    if (p.lives == 0)
      text("You lose!", view_x + width/2 - 100, view_y + height/2 - 100); 
    else if (p.lives > 0) 
      text("You win!", view_x + width/2 - 100, view_y + height/2 - 100); 
    text("Press SPACE to restart!", view_x + width/2 - 100, view_y + height/2 - 50); 
  }
}

void updateAll(){
  p.updateAnimation(); 
  resolvePlatformCollisions(p, platforms);
  enemy.update(); 
  enemy.updateAnimation();
  for(Sprite c: coins){
    ((AnimatedSprite)c).updateAnimation(); 
  }
  
  collectCoins(); 
  //checkDeath(); 
}

void checkDeath(){
  boolean collideEnemy = checkCollision(p, enemy); 
  boolean fallOffCliff = p.getBottom() > GROUND_LEVEL; 
  if(collideEnemy || fallOffCliff){
    p.lives--;
    temp = p.lives; 
    if(p.lives == 0) {
      isGameOver = true;
    } else {
      p.center_x = 100; 
      p.setBottom(GROUND_LEVEL); 
    }
  }
}

void collectCoins(){
  ArrayList <Sprite> coin_list = checkCollisionList(p, coins); 
  if(coin_list.size() > 0){
    for(Sprite coin: coin_list){
      numCoins++; 
      coins.remove(coin); 
    }
  }
  
  if(coins.size() == 0 && numCoins == 10)
    setup2(); 
  else if (coins.size() == 0)
    setup();
  
  if(numCoins == 20)
    isGameOver = true; 
  
}

void scroll(){
  float right_boundary = view_x + width - RIGHT_MARGIN; 
  if(p.getRight() > right_boundary){
    view_x += p.getRight() - right_boundary; 
  }
  float left_boundary = view_x + LEFT_MARGIN; 
  if(p.getLeft() < left_boundary){
    view_x -= left_boundary - p.getLeft(); 
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN; 
  if(p.getBottom() > bottom_boundary){
    view_y += p.getBottom() - bottom_boundary; 
  }
  float top_boundary = view_y + VERTICAL_MARGIN; 
  if(p.getTop() < top_boundary){
    view_y -= top_boundary - p.getTop(); 
  }
  
  translate(-view_x, -view_y); 
}

public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  s.center_y += 5; 
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  s.center_y -= 5; 
  if(col_list.size() > 0){
    return true; 
  }
  else 
    return false; 
}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  s.change_y += GRAVITY;
  s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls); 
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0); 
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    } 
    else if (s.change_y < 0){
      s.setTop(collided.getBottom()); 
    }
    s.change_y = 0; 
  }

  s.center_x += s.change_x;
  col_list = checkCollisionList(s, walls); 
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0); 
    if(s.change_x > 0){
      s.setRight(collided.getLeft());
    } 
    else if (s.change_x < 0){
      s.setLeft(collided.getRight()); 
    }
  }
}

boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else {
    return true;
  }
}

public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list; 
}

void keyPressed() {
  if(keyCode == RIGHT){
    p.change_x = MOVE_SPEED; 
  }
  else if (keyCode == LEFT){
    p.change_x = -MOVE_SPEED; 
  }
  else if (keyCode == UP){
    p.change_y = -MOVE_SPEED; 
  }
  else if (keyCode == DOWN){
    p.change_y = MOVE_SPEED; 
  }
  else if (key == 'e' && isOnPlatforms(p, platforms)){
    p.change_y = -JUMP_SPEED; 
  }  
  else if (key == 'a') 
    setup2(); 
  else if (isGameOver && key == ' ') 
    setup(); 
}

void keyReleased() {
  if(keyCode == RIGHT){
    p.change_x = 0; 
  }
  else if (keyCode == LEFT){
    p.change_x = 0; 
  }
  else if (keyCode == UP){
    p.change_y = 0; 
  }
  else if (keyCode == DOWN){
    p.change_y = 0; 
  }
}

void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String [] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("1")){
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if (values[col].equals("2")){
        Sprite s = new Sprite(snow, SPRITE_SCALE); 
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s); 
      }
      else if (values[col].equals("3")){
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE); 
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s); 
      }
      else if (values[col].equals("4")){
        Sprite s = new Sprite(crate, SPRITE_SCALE); 
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s); 
      }
      else if (values[col].equals("5")){
        Coin coin = new Coin(gold, SPRITE_SCALE); 
        coin.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        coin.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(coin); 
      }
      else if (values[col].equals("6")){
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + 4 * SPRITE_SIZE; 
        enemy = new Enemy(spider, 50/72.0, bLeft, bRight); 
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        //println("test");
      }
    } 
  }
}
