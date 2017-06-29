/* void drawTimeLinePlot(){
    noStroke();
    fill(255,255,0,40);

    for(int i=0; i < tmpList.size(); i++){
      Date h = ((Date)tmpList.get(i));
      int hh = (int)h.getHours();
      float theta = getTheta(hh,period);
      float fh = rtd.firstDate.getTime();
      float lh = rtd.lastDate.getTime();
      
      float r_max = map(count[hh], 0, getMax(count), 0, getDiameter()/2);
      
      float lastdh = lh;        //-1000000000;
      if(h.getTime() > lastdh) continue;
      
      float dotr = map(h.getTime()/10000, fh/10000, lh/10000, 0, r_max);
      //float dotr = map(h.getTime()/10000, fh/10000, lastdh/10000, 0, getDiameter()/2);glyphCの場合(半径全部使っても誤認しない)

      rect(dotr * cos(theta),dotr * sin(theta)*-1,1.2,1.2);
    }
    fill(255,255,255);
  }*/
  
  
/*    void rotateLabel(){
    
    int len = label.length();
    int t_angle = 160/len;
    pushMatrix();
    translate(x,ty*-1);
    for(int i = 0; i < len; i++){
      pushMatrix();
      rotate(radians(i*t_angle));
      translate(-radius,0);
      rotate(radians(-i*t_angle));
      text(label.charAt(i),0,0);
      popMatrix();
    }
    popMatrix();
  }*/
  
        //if(clickedTime == max_t_index) {  //translate(0,getDiameter()/2-getDiameter()/10);
       // drawTimeLinePlot(getDiameter()/2);
      //}
      
      
        //ある時間帯(1..24)において、時間間隔tにおけるイベント発生回数の分散/標準偏差をとる
  //どの月によく発生するのか？　5月だった　毎年の5月か？
  //どの時間帯に良く発生するのか？　20時だった　毎日の20時か？
  //毎日発生する場合：分散小さい　特別な提示は不要
  //分散大きい　局所的な日付がある　はずれ値のみを赤い点で表示する
  
  //はずれ値の算出法⇒平均値が安定する場合　平均から標準偏差の値の3倍離れているか
  
  //点の位置は円半径を基準とすべきで、発生回数でタイムラインの長さを決めてはいけない
  //つまりスターグリフと相性が悪く、この場合clockGlyphを用いることになる
  //clockGlyphはイベントの発生回数を色の明度で表す為、重なりに弱い
  //スターグリフは面積と、円の半径の比較2点から直感的に理解できる（他の時間帯と比較もしやすい）
  //重なりに弱いのはもう全部そうなので、石田くんの研究待ちという感じでもある..
  
      /*fill(255,255,255);
    ellipse(x, y , 3, 3);
    stroke(255);
    line(x, y, x, y-r_max + 6);*/
    
      /*for(int j = 1; j <= rateAxis; j++){     
        nr = map(count[i*rateAxis+j-1], 0, c_max, 0, r_max);
        dx += nr * cos(getTheta(i*rateAxis+j-1,period));
        dy += nr * sin(getTheta(i*rateAxis+j-1,period))*-1;
      }
      if(rateAxis > 1){
        dx /= rateAxis; dy /= rateAxis;
        double theta = PI - Math.atan(dy/dx);
        nr = (int)map(count_disc[i],0,c_disc_max,0,r_max);
        dx = nr * cos((float)theta);
        dy = nr * sin((float)theta)*-1;
      }
      */
      
      /*
          println(label);
    for(int i=0; i < tmpListByDays.size(); i++){
      ArrayList<Date> e_agg_h = (ArrayList<Date>)tmpListByDays.get(i);
      Date d = e_agg_h.get(0);
      print("["+d.getYear() + " " + d.getMonth() + " "+ d.getDate() +":");
      print(e_agg_h.size()+"],");
    }
    return tmpListByDays;
    */
    
      /*
  void drawBoxPlot() {
   int[] array;
   
   for (int i=0; i < count.length; i+= d_axi) {
   pushMatrix();
   int nextAxis = getNextAxis(i / d_axi);
   rotate(2*PI*nextAxis/period);
   
   int n = 0;
   for (HashMap.Entry<Integer, Event> entry : elist.entrySet()) {
   Event e = entry.getValue();
   if (e.countByHour[nextAxis] > 0) n++;
   }
   
   if(n <= 4) {popMatrix();continue;}
   array = new int[n];
   
   n=0;
   for (HashMap.Entry<Integer, Event> entry : elist.entrySet()) {
   Event e = entry.getValue();
   if (e.countByHour[nextAxis] > 0) array[n++] = e.countByHour[nextAxis];
   }
   
   array = sort(array);
   
   int MAX_Y = (int)map(count[i],0,count[max_t_index],0,(int)getDiameter()/2);
   int box_w = MAX_Y/6;
   stroke(gcl_h[nextAxis],192);
   line(0, 0, 0, -MAX_Y);
   
   float max = 0;
   float min = 1000;  
   
   float average = 0;
   float median = array[array.length/2];
   float first_quartile = array[(int)(array.length/2-1)/2];
   float third_quartile = array[(int)(array.length/2+1+array.length)/2];
   //float IQR = third_quartile - first_quartile;
   
   for (int ii=0; ii < array.length; ii++) {
   if (array[ii] > max) max = array[ii];
   if (array[ii] < min) min = array[ii];
   average += array[ii];
   }
   average /= array.length;
   
   float my = map(median, min, max, 0, MAX_Y);
   float ty = map(third_quartile, min, max, 0, MAX_Y);
   float fy = map(first_quartile, min, max, 0, MAX_Y);
   
   fill(gcl_h[nextAxis], 252 * 0.7); 
   //noStroke();
   rect(-box_w, -ty, box_w*2, ty-fy);
   
   // line(-box_w, -my, box_w, -my);
   //ellipse(0, -map(average, min, max, 0, MAX_Y), 4, 4); //ほんとは×型
   //line(-box_w*0.8, 0, box_w*0.8, 0);
   //line(-box_w*0.8, -MAX_Y, box_w*0.8, -MAX_Y);
   
   popMatrix();
   }
   }
   */