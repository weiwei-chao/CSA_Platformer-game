final static float MOVE_SPEED = 4;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = .6;
final static float JUMP_SPEED = 14; 

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

final static int NEUTRAL_FACING = 0;
final static int RIGHT_FACING = 1;
final static int LEFT_FACING = 2;

final static float WIDTH = SPRITE_SIZE *16;
final static float HEIGHT = SPRITE_SIZE *12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

//declare global variables
Player player;
//Player2 player2;
PImage snow, crate, red_brick, brown_brick, gold, spider, p;
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
ArrayList<Sprite> enemies;
float view_x;
float view_y;
int score;
int score2;
Enemy enemy;
boolean isGameOver;
int numCoins;
int numCoins2;
Coin c;

//initialize them in setup().
void setup(){
  size(800, 600);
  imageMode(CENTER);

  platforms = new ArrayList<Sprite>();
  coins = new ArrayList<Sprite>();
  enemies = new ArrayList<Sprite>();
  view_x = 0;
  view_y = 0;
 
  red_brick = loadImage("red.png");
  brown_brick = loadImage("brown.png");
  crate = loadImage("crate.png");
  snow = loadImage("snow.png");
  gold = loadImage("gold1.png");
  spider = loadImage("spider1.png");
  p = loadImage("player.png");
  //p2 = loadImage("zombie1.png");
  createPlatforms("map.csv");

  player = new Player(p, 0.8);
  player.setBottom(GROUND_LEVEL);
  player.center_x = 100;
  //player2 = new Player2(p2, 0.8);
  //player2.setBottom(GROUND_LEVEL);
  //player2.center_x = 100;
  numCoins = 0;
  isGameOver = false;
  
}

// modify and update them in draw().
void draw(){
  background(255);
  //scroll();
  
  //display
  displayAll();
  //update
  if(!isGameOver){
    updateAll();
    collectCoins();
    checkDeath();
  }
} 

void displayAll(){
  //display code
  player.display();
  //player2.display();
  for(Sprite enemy: enemies){
    enemy.display();
    enemy.update();
    ((AnimatedSprite)enemy).updateAnimation();
  }
  for(Sprite s: platforms)
    s.display();
  for(Sprite c: coins){
    c.display();
    ((AnimatedSprite)c).updateAnimation();
  }
  textSize(32);
  fill(255, 0, 0);
  text("Coins:" + score, view_x+50, view_y+100);
  text("Player 1 Lives:" + player.lives, view_x + 50, view_y+150);
  //text("Player 2 Lives:" + player2.lives, view_x + 50, view_y+200);
  
  if(isGameOver){
    fill(0, 0, 255);
    text("Game Over!", view_x+width/2-100, view_y+ height/2);
    if(player.lives <= 0){
      text("Lives:" + 0, view_x + 50, view_y+150);
      text("You Lose!", view_x +width/2-100, view_y+height/2 +50);
    }else{
      text("You Win!", view_x +width/2-100, view_y+height/2+50);
    }
    text("Press SPACE to restart!!", view_x +width/2-100, view_y+height/2+100);
  }
  
}

void updateAll(){
  //update object
  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  //player2.updateAnimation();
  //resolvePlatformCollisions(player2, platforms);
  enemy.update();
  enemy.updateAnimation();
  
  ArrayList<Sprite> collision_list = checkCollisionList(player, coins);
  if(collision_list.size() > 0){
    for(Sprite coin: collision_list){
       coins.remove(coin);
       score++;
    }
  }
  
  //ArrayList<Sprite> collision_list2 = checkCollisionList(player2, coins);
  //if(collision_list2.size() > 0){
  //  for(Sprite coin: collision_list2){
  //     coins.remove(coin);
  //     score2++;
  //  }
  //}
  //checkDeath();
}

void collectCoins(){
  ArrayList<Sprite> coin_list = checkCollisionList(player, coins);
  if(coin_list.size()>0){
    for(Sprite coin: coin_list){
      numCoins++;
      coins.remove(coin);
    }
  }
  
  //ArrayList<Sprite> coin_list2 = checkCollisionList(player2, coins);
  //if(coin_list2.size()>0){
  //  for(Sprite coin: coin_list){
  //    numCoins2++;
  //    coins.remove(coin);
  //  }
  //}
  
  //collect all coins to win!
  if(coins.size()==0){
    isGameOver = true;
  }
}

void checkDeath(){
  boolean collideEnemy = false;
  boolean fallOffCliff = player.getBottom() > GROUND_LEVEL;
  //boolean fallOffCliff2 = player2.getBottom() > GROUND_LEVEL;
  for(Sprite enemy: enemies){
    collideEnemy = checkCollision(player, enemy);
    if(collideEnemy || fallOffCliff){
    player.lives--;
    }
    if(player.lives ==0){
      isGameOver = true;
    }else{
      player.center_x = 100;
      player.setBottom(GROUND_LEVEL);
    }
    
    //collideEnemy = checkCollision(player2, enemy);
    //if(collideEnemy || fallOffCliff2){
    //player2.lives--;
    //}
    //if(player2.lives ==0){
    //  isGameOver = true;
    //}else{
    //  player2.center_x = 100;
    //  player2.setBottom(GROUND_LEVEL);
    //}
  }
}

void scroll(){
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if(player.getRight() > right_boundary){
    view_x += player.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if(player.getLeft() < left_boundary){
    view_x -= left_boundary - player.getLeft();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if(player.getBottom() > bottom_boundary){
    view_y += player.getBottom() - bottom_boundary;
  }
  float top_boundary = view_y + VERTICAL_MARGIN;
  if(player.getTop() < top_boundary){
    view_y -= top_boundary - player.getTop();
  }
  translate(-view_x, -view_y);
}

// returns true if sprite is one a platform.
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  // move down say 5 pixels
  s.center_y += 5;

  // check to see if sprite collide with any walls by calling checkCollisionList
  ArrayList<Sprite> collision_list = checkCollisionList(s, walls);
  
  // move back up 5 pixels to restore sprite to original position.
  s.center_y -= 5;
  
  // if sprite did collide with walls, it must have been on a platform: return true
  // otherwise return false.
  return collision_list.size() > 0; 
}

public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  // add gravity to change_y of sprite
  s.change_y += GRAVITY;
  
  // move in y-direction by adding change_y to center_y to update y position.
  s.center_y += s.change_y;
  
  // Now resolve any collision in the y-direction:
  // compute collision_list between sprite and walls(platforms).
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  
  /* if collision list is nonempty:
       get the first platform from collision list
       if sprite is moving down(change_y > 0)
         set bottom of sprite to equal top of platform
       else if sprite is moving up
         set top of sprite to equal bottom of platform
       set sprite's change_y to 0
  */
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0){
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }

  // move in x-direction by adding change_x to center_x to update x position.
  s.center_x += s.change_x;
  
  // Now resolve any collision in the x-direction:
  // compute collision_list between sprite and walls(platforms).   
  col_list = checkCollisionList(s, walls);

  /* if collision list is nonempty:
       get the first platform from collision list
       if sprite is moving right
         set right side of sprite to equal left side of platform
       else if sprite is moving left
         set left side of sprite to equal right side of platform
  */

  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_x > 0){
        s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0){
        s.setLeft(collided.getRight());
    }
  }}

boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else{
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


void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("1")){
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("2")){
        Sprite s = new Sprite(snow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("3")){
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("4")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("5")){
        c = new Coin(gold, SPRITE_SCALE);
        c.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        c.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(c);
      }
      else if(values[col].equals("6")){
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + 4 * SPRITE_SIZE;
        enemy = new Enemy(spider, 50/72.0, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        enemies.add(enemy);
      }
    }
  }
}
 

// called whenever a key is pressed.
void keyPressed(){
  if(keyCode == RIGHT){
    player.change_x = MOVE_SPEED;
  }
  else if(keyCode == LEFT){
    player.change_x = -MOVE_SPEED;
  }
  // add an else if and check if key pressed is 'a' and if sprite is on platforms
  // if true then give the sprite a negative change_y speed(use JUMP_SPEED)
  // defined above
  else if(keyCode == UP && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;
  }
  //reset
  else if(isGameOver && key == ' '){
    setup();
  }
  //else if(key == 'w'  && isOnPlatforms(player, platforms)){
  //  player2.change_y = -JUMP_SPEED;
  //}
  //else if(key == 'a'){
  //  player2.change_x = -MOVE_SPEED;
  //}
  //else if(key == 'd'){
  //  player2.change_x = MOVE_SPEED;
  //}
  //else if(key == 's'){
  //  player2.change_y = MOVE_SPEED;
  //}

}

// called whenever a key is released.
void keyReleased(){
  if(keyCode == RIGHT){
    player.change_x = 0;
  }
  else if(keyCode == LEFT){
    player.change_x = 0;
  }
  //else if(key == 'a'){
  //  player2.change_x = 0;
  //}
  //else if(key == 'd'){
  //  player2.change_x = 0;
  //}
}
