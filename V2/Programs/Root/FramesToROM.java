import java.io.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.awt.image.*;
import java.awt.geom.AffineTransform;

public class FramesToROM {
	public static void main(String[] args) {
		try {
			File framesFolder = new File("frames");
			if(!framesFolder.exists()) {
				System.out.println("Frames folder not found");
				if(new File("frames.bin").exists()) {
					System.out.println("...but frames.bin exists, so probably fine");
					System.exit(0);
				}else System.exit(1);
			}
			BufferedReader br = new BufferedReader(new FileReader(new File("./ba.regs.txt")));
			FileOutputStream fos = new FileOutputStream("frames.bin");
			int fileCount = framesFolder.listFiles().length;
			int[] buffer = new int[1024];
			double totalTime = 0;
			String lastLine = null;
			double musicScale = 1.645;
			int musicOffset = -43;
			long lastStamp = 0;
			for(int i = 0; i < fileCount; i++) {
				BufferedImage img = ImageIO.read(new File(String.format("frames/frame_%04d.png", i + 1)));
				BufferedImage scaled = new BufferedImage(85, 64, BufferedImage.TYPE_INT_ARGB);
				AffineTransform at = new AffineTransform();
				at.scale(85.0 / (double)img.getWidth(), 64.0 / (double)img.getHeight());
				AffineTransformOp scaleOp = new AffineTransformOp(at, AffineTransformOp.TYPE_BILINEAR);
				scaled = scaleOp.filter(img, scaled);
				for(int j = 0; j < 64; j++) {
					for(int k = 0; k < 128; k++) {
						int pixel = 0;
						if(k >= 21 && k < 21+85) {
							int rgb = scaled.getRGB(k - 21, j) & 0xFF;
							if(rgb > 128) pixel = 1;
						}
						int x = 127 - k;
						int y = 63 - j;
						if(pixel == 0) buffer[x + (y / 8) * 128] &= ~(1 << (7 - y & 7));
						else buffer[x + (y / 8) * 128] |= (1 << (7 - y & 7));
					}
				}
				
				musicOffset++;
				double lastTime = totalTime;
				while(musicOffset > 0) {
					String line = lastLine == null ? br.readLine() : lastLine;
					lastLine = null;
					if(line == null) break;
					String[] parts = line.split("-");
					long timestamp = Long.parseLong(parts[0]);
					int addr = Integer.parseInt(parts[1]);
					int val = Integer.parseInt(parts[2]);
					double timestampSecs = (double)(timestamp - lastStamp) / 1000000.0 * musicScale;
					lastStamp = timestamp;
					double diff = totalTime - lastTime;
					if(diff + timestampSecs >= 1.0/30.0) {
						lastLine = line;
						break;
					}
					fos.write(addr);
					fos.write(val);
					totalTime += timestampSecs;
				}
				fos.write(255);
				
				for(int l = 0; l < 1024; l++) fos.write(buffer[l]);
			}
			fos.close();
			br.close();
		}catch(Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
