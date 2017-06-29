import java.util.Date;

int text_max_size = 32;
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
      x += r_view * cos(theta);
      y += r_view * sin(theta);
      count[h]++;
    }
    x /= tmpList.size();
    y /= tmpList.size();
  }

  void drawNode() {
    noStroke();
    pushMatrix();
    translate(x, y * -1);

    if (clickedTime == -1 || clickedTime == max_t_index) {      
      glyph.draw(tmpList, count);

      if (display_g_frq) drawTimeLinePlot(getDiameter()/2);
    } else {
      fill(150, 200, 220, 50);
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



  float getDiameter() {
    float ar = 2 * sqrt(tmpList.size() / PI);
    float mr = sqrt(maxNodeSize / PI);
    ar *= (0.15 * r_view)/mr;

    return 10 + ar;
  }

  int getHoursFromDate(Date d) {
    return (int)(d.getHours() % period);
  }


}