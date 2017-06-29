import java.util.HashMap;
import java.util.TimeZone;
import java.text.*;

//hashmap: {{label,NODE},{"Tea",NODE},...}
//Node: label,{Date,"2017...","2016..."}

class ReadTemporalData{
  private Date firstDate;
  private Date lastDate;
  private HashMap<String,Node> hashmap = new HashMap<String,Node>();
  
  ReadTemporalData(String filename){
    String[] rows = loadStrings(filename);
    //SimpleDateFormat sdf  = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss a",java.util.Locale.ENGLISH);

    //最初に並べ替えしたほうがよい
    Date[] d_list = new Date[rows.length];
    
    for(int i = 1; i < rows.length; i++){ //i=0はラベルと仮定
      String[] pieces = split(rows[i],",");
      try{
        Date d = sdf.parse(pieces[2]);
        d_list[i]= d;
      } catch( ParseException e){
        System.out.print(e);
      }
    }
    Date dtmp;
    String stmp;
    int ja;
    for(int i = 2; i < d_list.length; i++){
      dtmp = d_list[i]; stmp = rows[i];
      for( ja = i; 1 < ja && d_list[ja - 1].getTime() > dtmp.getTime(); --ja){
        d_list[ja] = d_list[ja-1];
        rows[ja] = rows[ja-1];
      }
      d_list[ja] = dtmp;
      rows[ja] = stmp;
    }
    firstDate = d_list[1];
    lastDate = d_list[d_list.length - 1];
    
    for(int i = 1; i < rows.length; i++){
      String[] pieces = split(rows[i],",");
      //String pieces_t; 
      //Node node = hashmap.get(pieces[0]);
      Node node = hashmap.get(pieces[7]);

      if(node == null){
        node = new Node(pieces[7]);
      }
      //pieces[2] = pieces[2].replaceAll("T"," ");
      /*pieces_t = pieces[2];
        pieces_t = pieces_t.replaceAll("-","").substring(0,8); */
      try{
        Date d = sdf.parse(pieces[2]);
        node.addDate(d);
      } catch( ParseException e){
        System.out.print(e);
      }
      hashmap.put(pieces[7],node);
      
    }
  }
  
  void test(){
    for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
      Node node = entry.getValue();
      ArrayList list_h = node.getTmpListByHours();
      node.calcAverageByHour(list_h);
      node.calcVarianceByHour(list_h);
    }
  }
  
  void calcNodesPoint(){
    for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
      entry.getValue().calcPoint();
    }
    /*for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
      print(entry.getValue().label + " ");
      for(int i = 0; i < period; i++){
        print(entry.getValue().count[i] + " ");
      }
      println("");
    }*/
  }
  
  
  void drawNodes(){
    float  dmin   = 1000;
    String dlabel = "-";

    for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
      if(entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().drawBackEllipse();
    }

    for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
      if(entry.getValue().tmpList.size() > rangeDisplayNode) continue;
      entry.getValue().drawNode();
    
      float d = dist(mouseX - 350, mouseY - 350, entry.getValue().x, entry.getValue().y * -1);
      if(d <= 10 && d <= dmin){
        dlabel = entry.getKey();
        dmin = d;
      }
    }
        
    textAlign(CENTER,CENTER);
    
    if(display_label){ 
      for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
        if(entry.getValue().tmpList.size() > rangeDisplayNode) continue;
        entry.getValue().drawNodeLabel();
      }
    }
    
    if(dlabel != "-"){
      hashmap.get(dlabel).printDetail();
    }
  }
  
  void calcMaxNodeSize(){
    int s = 0;
    for(HashMap.Entry<String,Node> entry: hashmap.entrySet()){
      if(entry.getValue().tmpList.size() > s){
        s = entry.getValue().tmpList.size();
      }
    }
    maxNodeSize = s;
  }
  
}