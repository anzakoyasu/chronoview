class Glyph{
  int glyph_type;
  
  Glyph(int type){
    glyph_type = type;
  }
  
  void setGlyphType(int type){
    glyph_type = type;
  }
  
  void draw(ArrayList tmpList, int[] count){
    int max_t_index = getMaxIndex(count);
    
    switch(glyph_type) {
        //rateAxisいじれるバーをつけたい
      case '1': 
        glyph.drawStarGlyph(tmpList, count, max_t_index); 
        break;
      case '2': 
        glyph.drawStarGlyph(tmpList, count, max_t_index); 
        glyph.drawGlyph_a(tmpList, count, max_t_index);
        break;
      case '3': 
        glyph.drawGlyph_c(tmpList, count, max_t_index); 
        break;
      case '4': 
        //drawBoxPlot();
        glyph.drawGlyph_d(tmpList, count, max_t_index);
        break;
      case '5':
        glyph.drawGlyph_e(tmpList, count, max_t_index);
        break;

      default: 
        glyph.drawGlyph_a(tmpList, count, max_t_index);
        break;
      }
  }
  
  void drawStarGlyph(ArrayList tmpList, int[] count, int max_t_index) {
    float r_max = getDiameter(tmpList) / 2;
    int   c_max = count[max_t_index];

    fill(gcl_h[max_t_index], 252 * 0.7);

    int firstaxis = -1;
    int endaxis = -1;    

    float nr = 0;
    float dx=0, dy=0;

    beginShape();
    for (float i = 0; i < count.length; i+=d_axi) {
      endaxis = (int)(i / d_axi);
      int nextAxis = getNextAxis(i / d_axi, count);
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
  
  void drawGlyph_a(ArrayList tmpList, int[] count, int max_t_index) {
    float r_max = getDiameter(tmpList);
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi, count);
      int nr = (int)map(count[nextAxis], 0, count[max_t_index], 0, r_max/2);
      float dx = nr * cos(getTheta(nextAxis, period));
      float dy = nr * sin(getTheta(nextAxis, period)) * -1;
      stroke(gcl_h[nextAxis]);
      line(0, 0, dx, dy);
    }
  }
  
  void drawGlyph_c(ArrayList tmpList, int[] count, int max_t_index) {
    float r_max = 2*getDiameter(tmpList)/3;
    int   c_max = count[max_t_index];
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi, count);
      float nr = map(count[nextAxis], 0, c_max, 0, 252*0.9);     
      float start = 2 * PI * (i - 0.5) / (period) - PI/2;
      float next = 2 * PI * (i + d_axi - 0.5) / period - PI/2;

      //fill(gcl_h[nextAxis], nr);
      fill(gcl_h[max_t_index],nr);
      arc(0, 0, r_max, r_max, start, next);
    }
  }  
  
  void drawGlyph_d(ArrayList tmpList, int[] count, int max_t_index) {
    float r_max = getDiameter(tmpList);
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi, count);
      float nr = r_max / 6.5;
      float dx = nr * cos(getTheta(nextAxis, period));
      float dy = nr * sin(getTheta(nextAxis, period)) * -1;
      float al = map(count[nextAxis],0,count[max_t_index],0.4,0.9);
      fill(gcl_h[nextAxis], 255 * al);

      float ar = sqrt(count[nextAxis] / PI);
      float mr = sqrt(count[max_t_index] / PI);
      ar *= (0.355 * r_max/2)/mr;
      ellipse(dx, dy, ar, ar);
    }
  }
    
  void drawGlyph_e(ArrayList tmpList, int[] count, int max_t_index) {
    float r_max = getDiameter(tmpList);
    int   c_max = count[max_t_index];
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi, count);
      float nr = map(count[nextAxis], 0, c_max, 0, r_max);
      nr = sqrt(nr/PI)*10;
      float start = 2 * PI * (i - 0.5) / (period) - PI/2;
      float next = 2 * PI * (i + d_axi - 0.5) / period - PI/2;
      
      fill(gcl_h[nextAxis], 255);
      arc(0, 0, nr, nr, start, next);
    }
  }
  
  float getDiameter(ArrayList tmpList) {
    float ar = 2 * sqrt(tmpList.size() / PI);
    float mr = sqrt(maxNodeSize / PI);
    ar *= (0.15 * r_view)/mr;

    return 10 + ar;
  }
  
  //次に表示する軸を　離散化度合いの指標を元に選ぶ
  //現在：表示軸数で等分 等分された軸群の中でもっとも回数が多い軸を選ぶ
  int getNextAxis(float i, int[] count) {
    int vm = 0;
    int vmt= (int)i;   
    for (int j = 1; j <= d_axi; j++) {
      int index = (int)(i * d_axi + j - 1);
      if (index >= 24) continue;
      if (count[index] > vm) {
        vm = count[index];
        vmt = index;
      }
    }
    return vmt;
  }
  
 int getMaxIndex(int[] array) {
    int v=0, vt=0;
    for (int i=0; i<array.length; i++) {
      if (array[i] > v) {
        v = array[i];
        vt = i;
      }
    }
    return vt;
  }
}