import java.util.Date;

int text_max_size = 12;
float rateAxis = 0.3;
float d_axi = 1;

class Node {
  private String label;
  private int[] count;
  private int max_t_index = 0;

  private ArrayList<Date> tmpList;

  float[] averageByHour;
  float[] varianceByHour;

  private float x, y;

  Node(String str) {
    label = str;
    averageByHour  = new float[(int)period];
    varianceByHour = new float[(int)period];
    tmpList = new ArrayList<Date>();
  }

  ArrayList getTmpListByHours() { //時間帯単位で集約したtmpListを返す
    ArrayList tmpListByHours = new ArrayList();

    int lastHour = getHoursFromDate((Date)tmpList.get(0));
    tmpListByHours.add(new ArrayList<Date>());

    for (int i=0; i < tmpList.size(); i++) {
      ArrayList<Date> tlist = (ArrayList<Date>)tmpListByHours.get(tmpListByHours.size() - 1);

      Date d = tmpList.get(i);
      int ch = getHoursFromDate(d);
      if (lastHour == ch ) {//同じ時間帯はカウント
        tlist.add(d);
      }

      if (i+1 >= tmpList.size()) break;

      //違う時間帯になったら次サイクルへ
      int nh = getHoursFromDate(tmpList.get(i+1));
      if (lastHour != nh) {
        lastHour = nh;
        tmpListByHours.add(new ArrayList<Date>());
      }
    }
    return tmpListByHours;
  }

  ArrayList getTmpListByDays() { //日付単位で集約したtmpListを返す
    ArrayList tmpListByDays = new ArrayList();

    int lastDay = tmpList.get(0).getDate();
    tmpListByDays.add(new ArrayList<Date>());

    for (int i=0; i < tmpList.size(); i++) {
      ArrayList<Date> tlist = (ArrayList<Date>)tmpListByDays.get(tmpListByDays.size() - 1);

      Date d = tmpList.get(i);
      if (lastDay == d.getDate() ) {//同じ時間帯はカウント
        tlist.add(d);
      }

      if (i+1 >= tmpList.size()) break;

      //違う時間帯になったら次サイクルへ
      if (lastDay != tmpList.get(i+1).getDate() ) {
        lastDay = tmpList.get(i+1).getDate();
        tmpListByDays.add(new ArrayList<Date>());
      }
    }
    return tmpListByDays;
  }


  void drawBackEllipse() {
    noStroke();
    fill(128, 128, 128, 50);
    ellipse(x, y*-1, getDiameter(), getDiameter());
  }

  void addDate(Date d) {
    tmpList.add(d);
  }

  void calcPoint() {
    x = y = 0;
    count = new int[(int)period];
    float theta = 0;

    for (int i=0; i < tmpList.size(); i++) {
      int h = getHoursFromDate((Date)tmpList.get(i));
      theta = getTheta(h, period);
      x += r * cos(theta);
      y += r * sin(theta);
      count[h]++;
    }
    x /= tmpList.size();
    y /= tmpList.size();
  }

  void drawNode() {
    noStroke();

    max_t_index = getMaxIndex(count);
    float radius = getDiameter() / 2;
    pushMatrix();
    translate(x, y * -1);

    if (clickedTime == -1 || clickedTime == max_t_index) {
      noStroke();
      switch(glyph_type) {
        //rateAxisいじれるバーをつけたい
      case '1': 
        drawStarGlyph(); 
        break;
      case '2': 
        drawStarGlyph(); 
        drawGlyph_a();
        break;
      case '3': 
        drawGlyph_c(); 
        break;
      case '4': 
        //drawBoxPlot();
        drawGlyph_d();
        break;
      case '5':
        drawGlyph_e();
        break;

      default: 
        drawGlyph_a(); 
        break;
      }

      if (display_g_frq) drawTimeLinePlot(getDiameter()/2);
    } else {
      fill(150, 200, 220, 50);
      //ellipse(0, 0, radius * 2, radius * 2);
    }

    popMatrix();
  }

  void drawNodeLabel() {
    textSize(map(tmpList.size(), 0, maxNodeSize, 8, text_max_size));
    if (clickedTime == -1 || clickedTime == max_t_index) {  
      fill(255);
    } else {
      fill(50);
    }
    text(label, x, y * -1 - getDiameter()/4);
  }

  void drawStarGlyph() {
    float r_max = getDiameter() / 2;
    int   c_max = count[max_t_index];

    fill(gcl_h[max_t_index], 252 * 0.7);

    int firstaxis = -1;
    int endaxis = -1;    

    float nr = 0;
    float dx=0, dy=0;

    beginShape();
    for (float i = 0; i < count.length; i+=d_axi) {
      endaxis = (int)(i / d_axi);
      int nextAxis = getNextAxis(i / d_axi);
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

  //次に表示する軸を　離散化度合いの指標を元に選ぶ
  //現在：表示軸数で等分 等分された軸群の中でもっとも回数が多い軸を選ぶ
  int getNextAxis(float i) {
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
    //if(abs(count[i] - average) < /*3**/ sd){continue;} 
    //if(count[i] < average){continue;} 
    return vmt;
  }

  void drawTimeLinePlot(float diam) {
    ArrayList t_list_h = getTmpListByHours();

    for (int i = 0; i < t_list_h.size(); i++) {
      ArrayList<Date> list = (ArrayList)t_list_h.get(i); 
      Date d = list.get(0);
      int c_h = list.size();
      int h = d.getHours();
      
      float variance = varianceByHour[h];
      float sd = sqrt(variance);

      if (diam != 200 && c_h - averageByHour[h] <= 1.5 * sd) {
        continue;
      }

      long fh = rtd.firstDate.getTime();
      long lh = rtd.lastDate.getTime();

      if (d.getTime() > lh) continue;

      //float dotr = map(d.getTime()/10000, fh/10000, lh/10000, 0, r_max);  
      float dotr = map(d.getTime()/10000, fh/10000, lh/10000, 0, diam);//glyphCの場合(半径全部使っても誤認しない)

      fill(200 + c_h * 5, 200 * c_h * 5, 0);    
      float pr = diam; 
      if (pr < 100) pr = 100; 

      float size = map(c_h, 1, 20, 1.0 * pr/100, 6 * pr/100);
      noStroke();
      float theta = getTheta(h, period);
      ellipse(dotr * cos(theta), dotr * sin(theta)*-1, size, size);
      stroke(255);

      if (diam == 200 && c_h - averageByHour[h] > 1.5 * sd) {
        fill(255, 255, 255, 200);
        textSize(8);
        String str = new SimpleDateFormat("yyyy-MM-dd").format(d);
        text(str, dotr * cos(theta), dotr * sin(theta) * -1+5);
      }
    }
  }

  void printDetail() {
    pushMatrix();
    translate(600, -50);
    stroke(255);
    fill(255);
    text("Event:"+ label, 0, -260);
    text("Number of Event:" + tmpList.size(), 0, -240);


    noFill();
    ellipse(0, 0, 400, 400);
    for (int h = 0; h < period; h++) {
      float theta = getTheta(h, period);
      float x = (200 + 20) * cos(theta); 
      float y = (200 + 20) * sin(theta);
      text(h, x, y * -1);
    }

    noStroke();
    float r_max = 400;
    int   c_max = count[max_t_index];

    for (int i=0; i < count.length; i++) {
      float nr = map(count[i], 0, c_max, 0, 252*0.6); 
      float start = 2 * PI * (i - 0.5) / period - PI/2;

      fill(208, 228, 255, nr); 
      // fill(gcl_h[i],nr);
      arc(0, 0, r_max, r_max, start, start + 2 * PI/period);
    }
    drawTimeLinePlot(200);
    popMatrix();
  }

  void drawGlyph_a() {
    float r_max = getDiameter();
    //stroke(gcl_h[max_t_index]);
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi);
      int nr = (int)map(count[nextAxis], 0, count[max_t_index], 0, r_max/2);
      float dx = nr * cos(getTheta(nextAxis, period));
      float dy = nr * sin(getTheta(nextAxis, period)) * -1;
      stroke(gcl_h[nextAxis]);
      line(0, 0, dx, dy);
    }
  }

  void drawGlyph_c() {
    float r_max = 2*getDiameter()/3;
    int   c_max = count[max_t_index];
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi);
      float nr = map(count[nextAxis], 0, c_max, 0, 252*0.9);     
      float start = 2 * PI * (i - 0.5) / (period) - PI/2;
      float next = 2 * PI * (i + d_axi - 0.5) / period - PI/2;

      //fill(gcl_h[nextAxis], nr);
      fill(gcl_h[max_t_index],nr);
      arc(0, 0, r_max, r_max, start, next);
    }
  }

  void drawGlyph_d() {
    float r_max = getDiameter();
    //stroke(gcl_h[max_t_index]);
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi);
      //int nr = (1 + 1 + 1) / 3;//x方向の重心
      float nr = r_max / 6.5;
      float dx = nr * cos(getTheta(nextAxis, period));
      float dy = nr * sin(getTheta(nextAxis, period)) * -1;
      float al = 0.68; 
      al = map(count[nextAxis],0,count[max_t_index],0.2,0.8);
      fill(gcl_h[nextAxis], 255 * al);

      float ar = sqrt(count[nextAxis] / PI);
      float mr = sqrt(count[max_t_index] / PI);
      ar *= (0.355 * r_max/2)/mr;
      ellipse(dx, dy, ar, ar);
    }
  }
  
  
  void drawGlyph_e() {
    float r_max = getDiameter();//2 * getDiameter() / 3;
    int   c_max = count[max_t_index];
    for (float i=0; i < count.length; i+= d_axi) {
      int nextAxis = getNextAxis(i / d_axi);
      float nr = map(count[nextAxis], 0, c_max, 0, r_max);
      nr = sqrt(nr/PI)*10;
      float start = 2 * PI * (i - 0.5) / (period) - PI/2;
      float next = 2 * PI * (i + d_axi - 0.5) / period - PI/2;
      
      fill(gcl_h[nextAxis], 255);
      arc(0, 0, nr, nr, start, next);
    }
  }

  void calcAverageByHour(ArrayList list_h) {
    int[] num = new int[(int)period];

    for (int i=0; i < list_h.size(); i++) {
      ArrayList<Date> t_list = (ArrayList)list_h.get(i);
      int c = t_list.size();
      int h = t_list.get(0).getHours();
      averageByHour[h] += c;
      num[h]++;
    }

    for (int i=0; i < period; i++) {
      averageByHour[i] /= num[i];
    }
  }

  void calcVarianceByHour(ArrayList list_h) {
    int[] num = new int[(int)period];

    for (int i=0; i < list_h.size(); i++) {
      ArrayList<Date> t_list = (ArrayList)list_h.get(i);
      int c = t_list.size();
      int h = t_list.get(0).getHours();
      varianceByHour[h] += sq(c - averageByHour[h]);
      num[h]++;
    }

    for (int i=0; i < period; i++) {
      varianceByHour[i] /= num[i];
    }
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

  float getDiameter() {
    float ar = 2 * sqrt(tmpList.size() / PI);
    float mr = sqrt(maxNodeSize / PI);
    ar *= (0.15 * r)/mr;

    return 10 + ar;
  }

  int getHoursFromDate(Date d) {
    return (int)(d.getHours() % period);
  }

  void a() {
    float average = 0;
    float variance = 0;
    float sd = 0;
    for (int i=0; i < count.length; i++) {
      average += count[i];
    }
    average /= count.length;

    for (int i=0; i < count.length; i++) {
      variance += sq(count[i]-average);
    }
    variance /= count.length;
    sd = sqrt(variance);
  }
}