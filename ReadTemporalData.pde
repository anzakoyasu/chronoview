import java.util.HashMap;
import java.util.TimeZone;
import java.text.*;

class ReadTemporalData {
  private Date firstDate;
  private Date lastDate;
  private HashMap<String, Node> hashmap = new HashMap<String, Node>();

  ReadTemporalData(String filename) {
    String[] rows = loadStrings(filename);
    //SimpleDateFormat sdf  = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss a", java.util.Locale.ENGLISH);

    //最初に並べ替え
    Date[] d_list = new Date[rows.length];

    for (int i = 1; i < rows.length; i++) { //i=0はラベルと仮定
      String[] pieces = split(rows[i], ",");
      try {
        Date d = sdf.parse(pieces[2]);
        d_list[i]= d;
      } 
      catch( ParseException e) {
        System.out.print(e);
      }
    }
    
    Date dtmp;
    String stmp;
    int ja;
    for (int i = 2; i < d_list.length; i++) {
      dtmp = d_list[i]; 
      stmp = rows[i];
      for ( ja = i; 1 < ja && d_list[ja - 1].getTime() > dtmp.getTime(); --ja) {
        d_list[ja] = d_list[ja-1];
        rows[ja] = rows[ja-1];
      }
      d_list[ja] = dtmp;
      rows[ja] = stmp;
    }
    
    firstDate = d_list[1];
    lastDate  = d_list[d_list.length - 1];

    for (int i = 1; i < rows.length; i++) {
      String[] pieces = split(rows[i], ",");
      String   label  = pieces[7];
      Date time_stamp = new Date();
      
      try { time_stamp = sdf.parse(pieces[2]);} 
      catch( ParseException e) {System.out.print(e);}
      
      //pieces[2] = pieces[2].replaceAll("T"," ");
      if (isMatched(label, "\"")) {
        label = label.replace("\"", "");
      }
      if (isMatched(label, "/")) {
        label = split(label, "/")[0];
      }
      
      if (isMatched(label, "&")){
        String[] s = split(label, "&");
        for(int j =0; j < s.length; j++) {
          addNode(s[j], time_stamp);
        }
        continue;
      }
      addNode(label, time_stamp);
    }
  }
  
  boolean isMatched(String str, String target){
    return str.matches(".*" + target + ".*");
  }

  void addNode(String label, Date date) {
    Node node = hashmap.get(label);
    if (node == null) node = new Node(label);

    node.addDate(date);
    hashmap.put(label, node);
  }

  void calcNodeFeatures() {
    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      Node node = entry.getValue();
      ArrayList list_h = node.getTmpListByHours();
      node.calcAverageByHour(list_h);
      node.calcVarianceByHour(list_h);
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

    if (PLOT_MDS) plotMDS();
  }

  void plotMDS() {
    String[] rows = loadStrings("e_chicago_ctype.csv");
    for (int i = 1; i < rows.length; i++) {
      String[] pieces = split(rows[i], ",");
      Node node = hashmap.get(pieces[0]);

      if (node == null) {
        println("error:not find node");
        continue;
      }

      node.x = map(Float.parseFloat(pieces[1]), -26, 675, 20, 1150)*5;
      node.y = map(Float.parseFloat(pieces[2]), -77, 39, 80, 690)*3-750*2;
    }
  }


  void drawNodes() {
    float  dmin   = 1000;
    String dlabel = "-";

    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().drawBackEllipse();
    }

    for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
      if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().drawNode();

      float d = dist(mouseX - 350, mouseY - 350, entry.getValue().x, entry.getValue().y * -1);
      if (d <= 10 && d <= dmin) {
        dlabel = entry.getKey();
        dmin = d;
      }
    }

    textAlign(CENTER, CENTER);

    if (display_label) { 
      for (HashMap.Entry<String, Node> entry : hashmap.entrySet()) {
        if (entry.getValue().tmpList.size() > rangeDisplayNode) continue;
        entry.getValue().drawNodeLabel();
      }
    }

    if (dlabel != "-") {
      hashmap.get(dlabel).printDetail();
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