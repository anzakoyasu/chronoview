import java.math.BigDecimal;

ReadTemporalData rtd;

int glyph_type = '1';

int r = 300;
float period = 24;
int clickedTime = -1;

int maxNodeSize = 0;
boolean display_label = true;
boolean display_g_frq = false;

int rangeDisplayNode = 0;

/*
color[] gcl_h = 
{#ee0026,#fe4418,#ff6c0c,#fe8d00,#fca900,#fcc600,#fce501,#d2dc0c
 ,#a3d114,#78be2b,#4eac38,#309c4a,#259260,#0b8874,#0c787d,#0c6784
 ,#105488,#184389,#16308a,#201988,#4e057f,#6f0074,#8c006c,#ac0066};
*/

color[] gcl_h = 
{#f9344c,#fb4938,#fd662d,#ff8124,#ff9b15,#ffb61d,#ffd126,#ffed2f
,#d9e62f,#add72c,#88c83a,#6bba4b,#47ac59,#2fa46d,#22a286,#209998
,#218ea5,#2680ae,#3670b0,#5e66ae,#8461ac,#a65aa9,#c2549f,#dc4d95};

color[] gcl_hq =
{#253532,#2c433e,#33524b,#3a6158,#427066,#498074,#509082,#57a090,#5fb19f,#66c2ae};

void setup(){
  size(1200, 700);
  smooth();
  
  rtd = new ReadTemporalData("chicago_crime_10000.csv");
  rtd.calcNodesPoint();
  rtd.calcMaxNodeSize();
  rtd.test();
  
  d_axi = (int)(period/(period*rateAxis));
  rangeDisplayNode = maxNodeSize;
}

void draw(){
  background(0);
  textSize(12);
  
  stroke(255);
  noFill();
  ellipse(350, 350, r * 2, r * 2);
  
  translate(350,350);
  
  textAlign(CENTER);
  fill(255);
  
  rtd.calcMaxNodeSize();
  
  clickedTime = -1;
  for(int h = 0; h < period; h++){
    float theta = getTheta(h, period);
    float x = (r + 20) * cos(theta); 
    float y = (r + 20) * sin(theta);
    fill(gcl_h[h]);
    text(h, x, y * -1);
    
    if(dist(x, y * -1, mouseX-350, mouseY-350) < 50){
      clickedTime = h;
    }
  }
  fill(255);
  rtd.drawNodes();
  
  translate(400,240);
  
  stroke(255);
  textSize(12);fill(255);
  text("rate of number of axes", 150, -20);
  line(0,0,300,0);
  text("range of display Nodes", 150, 60);
  line(0,80,300,80);
  
  if(mouseX > 750 && mouseY > 550 && mouseX <= 1080 && mouseY < 620){
    rateAxis = (mouseX - 750)/300.0;
    
    BigDecimal bd = new BigDecimal(rateAxis);
    bd = bd.setScale(1,BigDecimal.ROUND_DOWN);
    rateAxis = bd.floatValue();
    if(rateAxis > 1.0) rateAxis = 1.0;
    if(rateAxis < 0.05) rateAxis = 0.1;
    
    println(rateAxis);
    d_axi = period/(period*rateAxis);
    rtd.calcNodesPoint();
  }
  
  if(mouseX > 750 && mouseY > 630 && mouseX <= 1080 && mouseY < 720){
    rangeDisplayNode = (int)map((mouseX - 750)/300.0, 0, 1, 0, maxNodeSize);
  }
}

float getTheta(float t, float period){
  return PI/2 - 2*PI*(t/period);
}

void keyPressed(){
  
  if(key == 't'){
    display_label = !display_label;
  }
  
  if(key == 'f'){
    display_g_frq = !display_g_frq;
  }
  
  if(key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key =='0'){
    glyph_type = key;
    
    if(key == '1'){ rateAxis = 1; }
    if(key == '2'){ rateAxis = 0.3; }
    
    d_axi = (int)(period/(period*rateAxis));
    rtd.calcNodesPoint();
  }   
}