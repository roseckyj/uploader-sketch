import java.net.URLConnection;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.OutputStreamWriter;
import java.nio.file.Files;

class Uploader {
  private String pool;
  
  public Uploader(String pool) {
    this.pool = pool;
  }
  
  public void capture() {
    String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "-"  + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
    String path = "uploader/capture-" + timestamp + ".png";
    saveFrame(path);
    
    try {
      String url = "https://processing-upload.herokuapp.com/send";
      //String url = "http://localhost/send";
      String charset = "UTF-8";
      File binaryFile = new File(sketchPath() + "/" + path);
      String boundary = Long.toHexString(System.currentTimeMillis()); // Just generate some unique random value.
      String CRLF = "\r\n"; // Line separator required by multipart/form-data.
      
      URLConnection connection = new URL(url).openConnection();
      connection.setDoOutput(true);
      connection.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
      
      OutputStream output = connection.getOutputStream();
      PrintWriter writer = new PrintWriter(new OutputStreamWriter(output, charset), true);
      
      // Send pool param.
      writer.append("--" + boundary).append(CRLF);
      writer.append("Content-Disposition: form-data; name=\"pool\"").append(CRLF);
      writer.append("Content-Type: text/plain; charset=" + charset).append(CRLF);
      writer.append(CRLF).append(this.pool).append(CRLF).flush();
      
      // Send image file.
      writer.append("--" + boundary).append(CRLF);
      writer.append("Content-Disposition: form-data; name=\"image\"; filename=\"" + binaryFile.getName() + "\"").append(CRLF);
      writer.append("Content-Type: image/png").append(CRLF);
      writer.append("Content-Transfer-Encoding: binary").append(CRLF);
      writer.append(CRLF).flush();
      Files.copy(binaryFile.toPath(), output);
      output.flush();
      writer.append(CRLF).flush();
  
      // End of multipart/form-data.
      writer.append("--" + boundary + "--").append(CRLF).flush();
      
      
      // Request is lazily fired whenever you need to obtain information about response.
      int responseCode = ((HttpURLConnection) connection).getResponseCode();
      if (responseCode == 200) {
        println("Moment was captured");
      } else {
        println("There was an error with the capture, server responded with response code " + responseCode);
      }
    
    } catch (Exception e) {
      println(e);
    }
  }
}
