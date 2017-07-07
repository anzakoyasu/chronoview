class ChronoMain {
  ReadTemporalData rtd;
  HashMap<String, Node> hashmap;
  
  ChronoMain(String filename){
    rtd = new ReadTemporalData();
    hashmap = rtd.readData(filename);
  }
  
  void initialize(){
    calcNodesPoint();
    calcMaxNodeSize();
    calcNodeFeatures();
  }
  
  void calcNodeFeatures() {
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      Node node = entry.getValue();
      ArrayList list_h = node.getTmpListByHours();
      node.averageByHour = node.calcAverageByHour(list_h);
      node.varianceByHour = node.calcVarianceByHour(list_h);
    }
  }

  void calcNodesPoint() {
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      entry.getValue().calcPoint();
    }
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      print(entry.getValue().label + ", ");
      for (int i = 0; i < period; i++) {
        print(entry.getValue().count[i]);
        if (i != period - 1) print(",");
      }
      println("");
    }
    sparkClouds();
    //if (PLOT_MDS) plotMDS();
  }

  void plotMDS() {
    String[] rows = loadStrings("gene_euc_result.csv");
    for (int i = 1; i < rows.length; i++) {
      String[] pieces = split(rows[i], ",");
      Node node = hashmap.get(pieces[0]);

      if (node == null) {
        println("error:not find node");
        continue;
      }

      node.x = map(Float.parseFloat(pieces[1]), -132, 63, 20, 1150)*1.35-340*0.8;
      node.y = map(Float.parseFloat(pieces[2]), -14, 160, 80, 690)*1.5-450*1.8+50;
    }
  }
  
  void sparkClouds(){
    float sx=-120,sy=-150;
    
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().x = sx;
      entry.getValue().y = sy;
      
      sx+=70;
      if(sx > 770){
        sx = -120;
        sy +=70;
      }
    }
  }


  void drawNodes() {
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().drawBackEllipse();
    }
    
    float  dmin   = 1000;
    String dlabel = "-";
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      
      Node node = entry.getValue();
      
      float d = dist(mouseX - 350, mouseY - 350, node.x, node.y * -1);
      if (d <= 10 && d <= dmin) {
        dlabel = entry.getKey();
        dmin = d;
      }
      
      noStroke();
      pushMatrix();
      translate(node.x, node.y * -1);

      if (clickedTime == -1 || clickedTime == node.max_t_index) {      
        glyph.draw(node);
        if (display_g_frq) {
          node.drawTimeLinePlot(node.getDiameter()/2);
        }
      }
      popMatrix();
    }

    textAlign(CENTER, CENTER);
    if (dlabel != "-") hashmap.get(dlabel).printDetail();
    
    if (!display_label) return; 
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().drawNodeLabel();
    }
  }

  void calcMaxNodeSize() {
    int s = 0;
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > s) {
        s = entry.getValue().tmpList.size();
      }
    }
    maxNodeSize = s;
  }
  
}