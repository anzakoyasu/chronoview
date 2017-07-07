class Glyph{
  int glyph_type;
  
  ArrayList<Date> tmpList;
  int[] count;
  int max_t_index;
  float[] pday;
  
  Glyph(int type){
    glyph_type = type;
  }
  
  void setGlyphType(int type){
    glyph_type = type;
  }
  
  void draw(Node node){
    tmpList = node.tmpList;
    count = node.count;
    max_t_index = node.max_t_index;
    pday = node.pday;
    
    switch(glyph_type) {
        //rateAxisいじれるバーをつけたい
      case '1': 
        glyph.drawStarGlyph(); 
        break;
      case '2': 
        glyph.drawStarGlyph(); 
        glyph.drawGlyph_a();
        break;
      case '3': 
        glyph.drawGlyph_c(); 
        break;
      case '4': 
        //drawBoxPlot();
        glyph.drawGlyph_d();
        break;
      case '5':
        glyph.drawGlyph_e();
        break;

      default: 
        glyph.drawGlyph_a();
        break;
      }
  }
  
  void drawStarGlyph() {
    float r_max = getDiameter(tmpList) / 2;
    int   c_max = count[max_t_index];

    fill(gcl_h[max_t_index], 252 * 0.7);

    int firstaxis = -1;
    int endaxis = -1;    

    float nr = 0;
    float dx=0, dy=0;

    beginShape();
    for (float i = 0; i < count.length; i+=axi_step) {
      endaxis = (int)(i / axi_step);
      int nextAxis = getNextAxis(i / axi_step, count);
      if (firstaxis == -1) { 
        firstaxis = nextAxis;
      }
      nr = map(count[nextAxis], 0, c_max, 0, r_max);
      dx = nr * cos(getTheta(nextAxis, period ));
      dy = nr * sin(getTheta(nextAxis, period ))*-1;
      vertex(dx, dy);
    }

    nr = map(count[firstaxis], 0, c_max, 0, r_max);
    dx = nr * cos(getTheta(firstaxis, period ));
    dy = nr * sin(getTheta(firstaxis, period )) * -1;
    vertex(dx, dy);
    endShape(CLOSE);
  }
  
  void drawGlyph_a() {
    float r_max = getDiameter(tmpList);
    for (float i=0; i < count.length; i+= axi_step) {
      int nextAxis = getNextAxis(i / axi_step, count);
      int nr = (int)map(count[nextAxis], 0, count[max_t_index], 0, r_max/2);
      float dx = nr * cos(getTheta(nextAxis, period));
      float dy = nr * sin(getTheta(nextAxis, period)) * -1;
      stroke(gcl_h[nextAxis]);
      line(0, 0, dx, dy);
    }
  }
  
  void drawGlyph_c() {
    float r_max = 2*getDiameter(tmpList)/3;
    int   c_max = count[max_t_index];
    for (float i=0; i < count.length; i+= axi_step) {
      int nextAxis = getNextAxis(i / axi_step, count);
      float nr = map(count[nextAxis], 0, c_max, 0, 252*0.9);     
      float start = 2 * PI * (i - 0.5) / (period) - PI/2;
      float next = 2 * PI * (i + axi_step - 0.5) / period - PI/2;

      fill(gcl_h[nextAxis], nr);
      //fill(gcl_h[max_t_index],nr);
      arc(0, 0, r_max, r_max, start, next);
    }
  }  
  
  void drawGlyph_d() {
    float r_max = getDiameter(tmpList);
    for (int i=0; i < count.length; i+= axi_step) {
      int nextAxis = getNextAxis(i / axi_step, count);
      float nr = r_max / 6.5;
      float dx = nr * cos(getTheta(nextAxis, period));
      float dy = nr * sin(getTheta(nextAxis, period)) * -1;
      float al = map(count[nextAxis],0,count[max_t_index],0.4,0.9);
      fill(gcl_h[nextAxis], 255 * al);
      if(pday[i] <= 0.25) fill(255,255,255,255*al);

      float ar = sqrt(count[nextAxis] / PI);
      float mr = sqrt(count[max_t_index] / PI);
      ar *= (0.3 *r_max/2)/mr;
      ellipse(dx, dy, ar, ar);
    }
  }
    
  void drawGlyph_e() {
    float r_max = getDiameter(tmpList);
    int   c_max = count[max_t_index];
    for (int i=0; i < count.length; i+= axi_step) {
      int nextAxis = getNextAxis(i / axi_step, count);
      float nr = map(sqrt(count[nextAxis]) , 0, sqrt(c_max), 0, r_max*0.8);
      //float nr = sqrt(count[nextAxis]) * 10;
      float start = 2 * PI * (i - 0.5) / (period) - PI/2;
      float next = 2 * PI * (i + axi_step - 0.5) / period - PI/2;
      
      fill(gcl_h[nextAxis], 255);
      arc(0, 0, nr, nr, start, next);
    }
  }
  
  void drawGlyph_f() {
    float r_max = getDiameter(tmpList);
    int   c_max = count[max_t_index];
    for (float i=0; i < count.length; i+= axi_step) {
      
    }
  }
  
  float getDiameter(ArrayList tmpList) {
    float ar = 2 * sqrt(tmpList.size() / PI);
    float mr = sqrt(maxNodeSize / PI);
    ar *= (0.15 * r_view)/mr;

    return 10 + ar;
  }
  
  int[] aggressionCount(int[] count){
    int[] agc = new int[(int)(count.length / axi_step)];
    println(agc.length + "," + axi_step);
    for(int i=0; i < count.length; i++){
      agc[(int)(i /axi_step)] = count[i];
    }
    return agc;
  }
  
  //次に表示する軸を　離散化度合いの指標を元に選ぶ
  //現在：表示軸数で等分 等分された軸群の中でもっとも回数が多い軸を選ぶ
  int getNextAxis(float i, int[] count) {
    int vm = 0;
    int vmt= (int)i;   
    for (int j = 1; j <= axi_step; j++) {
      int index = (int)(i * axi_step + j - 1);
      if (index >= 24) continue;
      if (count[index] > vm) {
        vm = count[index];
        vmt = index;
      }
    }
    return vmt;
  }
  
  int getNextAxisCount(float i, int[] count) {
    int v = 0;
    for (int j = 1; j <= axi_step; j++) {
      int index = (int)(i * axi_step + j - 1);
      if (index >= 24) continue;
      v = count[index];
      
    }
    return v;
  }
  
}