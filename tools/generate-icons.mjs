/**
 * Generates Quby brand favicons and launcher icons from SVG sources.
 * Run: npm install sharp --no-save && node tools/generate-icons.mjs
 */
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import sharp from "sharp";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.join(__dirname, "..");

const iconSvg = fs.readFileSync(path.join(root, "assets/icon/icon.svg"));
const foregroundSvg = fs.readFileSync(path.join(root, "assets/icon/icon_foreground.svg"));

async function writePng(svg, outPath, size, { alpha = false } = {}) {
  let pipeline = sharp(svg, { density: 300 }).resize(size, size);
  if (alpha) pipeline = pipeline.ensureAlpha();
  await pipeline.png().toFile(outPath);
  console.log("Wrote", outPath);
}

async function writeIco(svg, outPath, size = 32) {
  const pngBuffer = await sharp(svg, { density: 300 }).resize(size, size).png().toBuffer();
  // Minimal ICO: single 32x32 PNG embedded
  const pngSize = pngBuffer.length;
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0); // reserved
  header.writeUInt16LE(1, 2); // type: icon
  header.writeUInt16LE(1, 4); // count: 1 image

  const entry = Buffer.alloc(16);
  entry.writeUInt8(size === 256 ? 0 : size, 0); // width
  entry.writeUInt8(size === 256 ? 0 : size, 1); // height
  entry.writeUInt8(0, 2); // color count
  entry.writeUInt8(0, 3); // reserved
  entry.writeUInt16LE(1, 4); // planes
  entry.writeUInt16LE(32, 6); // bit count
  entry.writeUInt32LE(pngSize, 8); // bytes in resource
  entry.writeUInt32LE(22, 12); // offset

  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, Buffer.concat([header, entry, pngBuffer]));
  console.log("Wrote", outPath);
}

async function main() {
  const outputs = [
    [iconSvg, path.join(root, "assets/icon/icon.png"), 1024, {}],
    [foregroundSvg, path.join(root, "assets/icon/icon_foreground.png"), 1024, { alpha: true }],
    [iconSvg, path.join(root, "web/favicon.png"), 32, {}],
    [iconSvg, path.join(root, "web/icons/Icon-192.png"), 192, {}],
    [iconSvg, path.join(root, "web/icons/Icon-512.png"), 512, {}],
    [iconSvg, path.join(root, "web/icons/Icon-maskable-192.png"), 192, {}],
    [iconSvg, path.join(root, "web/icons/Icon-maskable-512.png"), 512, {}],
    [iconSvg, path.join(root, "dashboard/app/icon.png"), 32, {}],
    [iconSvg, path.join(root, "dashboard/app/apple-icon.png"), 180, {}],
  ];

  for (const [svg, out, size, opts] of outputs) {
    fs.mkdirSync(path.dirname(out), { recursive: true });
    await writePng(svg, out, size, opts);
  }

  // SVG favicon for modern browsers
  fs.copyFileSync(
    path.join(root, "assets/icon/icon.svg"),
    path.join(root, "dashboard/app/icon.svg"),
  );
  console.log("Wrote dashboard/app/icon.svg");

  await writeIco(iconSvg, path.join(root, "dashboard/public/favicon.ico"), 32);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
