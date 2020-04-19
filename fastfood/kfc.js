// found a directory listing, moved to python

const fs = require('fs');
const puppeteer = require('puppeteer');

const base_URL = `https://locations.kfc.com/`//`https://maps.google.com`;//`https://www.google.com/maps/@${lat_init},${lon_init},3a,75y,182.14h,98.61t/data=!3m6!1e1!3m4!1sqL97FDTbhSXGPhQC_v_-xQ!2e0!7i16384!8i8192`;
const completed_file = 'kfc/completed.txt';
const all_zips_file = 'US_zips.txt';
const err_file = 'kfc/error.txt';
// var search_str = '02155';
const batch_size = 500;
var innerHTMLs = [];

//var zips = ['02155','02153'];

fs.writeFile(completed_file, '', { flag: 'wx' }, function (err) { });
fs.writeFile(err_file, '', { flag: 'wx' }, function (err) { });

(async () => {
  const browser = await puppeteer.launch({
    headless: false,
    args: ['--window-size=1920,1040'],
    slowMo: 7//700
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1040 });
  await page.goto(base_URL);

  while (true) {
    buff = fs.readFileSync(completed_file, 'utf-8');//, function(err,buff) {
    completed_zips = buff.split('\n').filter(line => !line.includes('----'));

    buff = fs.readFileSync(all_zips_file, 'utf-8');//, function(err,buff) {
    all_zips = buff.split('\n');
    all_zips = all_zips.filter(zip => !completed_zips.includes(zip.trim()));

    for (let i = all_zips.length - 1; i > 0; i--) {
      const k = Math.floor(Math.random() * (i + 1));
      [all_zips[i], all_zips[k]] = [all_zips[k], all_zips[i]];
    }

    var zips_batch = all_zips.slice(0, batch_size);//['02155','02153'];
    for (var j = 0; j < zips_batch.length; j++) {
      search_str = zips_batch[j];
      try {
        await page.waitForSelector('input.search-input')
        await page.$eval('input.search-input', (el, value) => el.value = value, search_str);
        await page.click('button.search-button');
        //await page.waitForSelector("div.location-list-results");
        await page.waitForSelector("div.Locator-results");
        // const found = await page.evaluate(() => window.find("there are no locations"));
        let innerHTML = await page.$eval('div.Locator-results', elt => elt.innerHTML);
        innerHTMLs.push(innerHTML);
        await page.waitFor(Math.random() * 4000 + 000);
        console.log(j.toString() + ' ' + zips_batch[j]);
      }
      catch (e) {
        fs.appendFileSync(err_file, search_str + '\n');
        print('error: ' + search_str);
      }

    }
    save_file = 'kfc/' + Date.now().toString() + '.JSON';
    fs.writeFileSync(save_file, JSON.stringify(innerHTMLs));
    fs.appendFileSync(completed_file, save_file + '------------\n');
    fs.appendFileSync(completed_file, zips_batch.join('\n') + '\n');
    console.log('saved to ' + save_file);
    innerHTMLs = [];
  }
}

)();

