import java.io.*;

public class MakeBootable {
	public static void main(String[] args) {
		try {
			String romTitle = args[1];
			FileInputStream fis = new FileInputStream(args[0]);
			FileOutputStream fos = new FileOutputStream("bootable.bin");
			for(int i = 0; i < romTitle.length(); i++) {
				char c = romTitle.charAt(i);
				fos.write(c & 0xFF);
			}
			fos.write(0);
			int len = 0;
			while(fis.available() > 0) {
				len++;
				fos.write(fis.read());
			}
			for(int i = len; i < 4096; i++) fos.write(0);
			fos.close();
			fis.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
