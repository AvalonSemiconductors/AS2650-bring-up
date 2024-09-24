import java.io.*;

public class ToVerilogHex {
	public static void main(String[] args) {
		try {
			if(args.length < 2) {
				System.out.println("ToVerilogHex [infile] [outfile]");
				System.exit(1);
			}
			int limit = 8*1024*1024;
			if(args.length >= 3) limit = Integer.parseInt(args[2]);
			byte[] image = new byte[limit];
			FileInputStream fis = new FileInputStream(new File(args[0]));
			fis.read(image);
			BufferedWriter bw = new BufferedWriter(new FileWriter(new File(args[1])));
			//bw.write("43 48 49 52 50 21 00");
			//bw.newLine();
			for(int i = 0; i < image.length; i++) {
				bw.write(String.format("%02x ", image[i] & 0xFF));
				if((i+1)%16==0) bw.newLine();
			}
			fis.close();
			bw.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
