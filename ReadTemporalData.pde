import java.util.HashMap;
import java.util.TimeZone;
import java.text.*;

class ReadTemporalData {
  ReadTemporalData() { 
  }
  
  HashMap readData(String filename){
    HashMap<String, Node> hashmap = new HashMap<String, Node>();
    String[] rows = loadStrings(filename);
    SimpleDateFormat sdf  = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    //SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss a", java.util.Locale.ENGLISH);

    //最初に並べ替え
    Date[] d_list = new Date[rows.length];

    for (int i = 1; i < rows.length; i++) { //i=0はラベルと仮定
      String[] pieces = split(rows[i], ",");
      try {
        pieces[2] = pieces[2].replaceAll("T"," ");
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
    for (int i = 1; i < d_list.length; i++) {
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
      String   label  = pieces[0];
      Date time_stamp = new Date();
      
      try { pieces[2] = pieces[2].replaceAll("T"," ");time_stamp = sdf.parse(pieces[2]);} 
      catch( ParseException e) {System.out.print(e);}
      
      if (isMatched(label, "\"")) {
        label = label.replace("\"", "");
      }
      if (isMatched(label, "/")) {
        label = split(label, "/")[0];
      }

      if (isMatched(label, "&")){
        String[] s = split(label, "&");
        for(int j =0; j < s.length; j++) {
          addNode(s[j], time_stamp, hashmap);
        }
        continue;
      }
      addNode(label, time_stamp, hashmap);
    }
    
    return hashmap;
  }
  
  boolean isMatched(String str, String target){
    return str.matches(".*" + target + ".*");
  }

  void addNode(String label, Date date, HashMap<String,Node> hashmap) {
    Node node = hashmap.get(label);
    if (node == null) node = new Node(label);

    node.addDate(date);
    hashmap.put(label, node);
  }

}