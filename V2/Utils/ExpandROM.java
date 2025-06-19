import java.io.*;

public class ExpandROM {
	public static void main(String[] args) {
		try {
			FileInputStream fis = new FileInputStream(new File(args[0]));
			int aaa = 0;
			FileOutputStream fos = new FileOutputStream("expanded.bin");
			while(fis.available() > 0) {
				fos.write(fis.read());
				aaa++;
			}
			int targSize = Integer.parseInt(args[1]);
			if(aaa > targSize) {
				System.err.println("Input already larger than requested size. You probably did not intend for this.");
				System.exit(1);
			}
			for(int i = aaa; i < targSize; i++) fos.write(0xFF);
			fos.close();
			fis.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
