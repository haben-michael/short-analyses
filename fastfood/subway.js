const puppeteer = require('puppeteer');
const fs = require('fs');

const base_URL = `https://www.subway.com/en-US/FindAStore`//`https://maps.google.com`;//`https://www.google.com/maps/@${lat_init},${lon_init},3a,75y,182.14h,98.61t/data=!3m6!1e1!3m4!1sqL97FDTbhSXGPhQC_v_-xQ!2e0!7i16384!8i8192`;
const completed_file = 'subway/completed.txt';
const all_zips_file = 'US_zips.txt';
const err_file = 'subway/error.txt';
var search_str = '02155';
const batch_size = 500;
var innerHTMLs = [];

//var zips = ['02155','02153'];


(async () => {
  const browser = await puppeteer.launch({
    headless:  true,// false,
    args: [ '--window-size=1920,1040'] ,
    slowMo:7//700
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1920, height: 1040 });
  await page.goto(base_URL);

  buff = fs.readFileSync(completed_file, 'utf-8');//, function(err,buff) {
  completed_zips = buff.split('\n').filter(line => !line.includes('----'));
  
  buff = fs.readFileSync(all_zips_file, 'utf-8');//, function(err,buff) {
  all_zips = buff.split('\n');
  all_zips = all_zips.filter(zip => !completed_zips.includes(zip.trim()));

  for (let i = all_zips.length - 1; i > 0; i--) {
    const k = Math.floor(Math.random() * (i + 1));
    [all_zips[i], all_zips[k]] = [all_zips[k], all_zips[i]];
}

  while (true) {
    var zips_batch = all_zips.slice(0,batch_size);//['02155','02153'];
    for (var j = 0; j<zips_batch.length; j++) {
      search_str = zips_batch[j];
      try {
      await page.waitForSelector('.searchLocationInput')
      await page.$eval('.searchLocationInput', (el,value) => el.value = value,search_str);
      await page.click('.btnDoSearch');
      await page.waitForSelector("div.location");
      let innerHTML = await page.$eval('div.FWHLocatorList', elt => elt.innerHTML);
      innerHTMLs.push(innerHTML);
      await page.waitFor(Math.random()*4000+000);
      console.log(j.toString() + ' ' + zips_batch[j]);
      }
      catch(e) {
        fs.appendFileSync(err_file,search_str);
      }
      
    } 
    save_file = 'subway/'+Date.now().toString()+'.JSON';
    fs.writeFileSync(save_file,JSON.stringify(innerHTMLs));
    fs.appendFileSync(completed_file,save_file+'------------\n');
    fs.appendFileSync(completed_file,zips_batch.join('\n')+'\n');
    console.log('saved to '+save_file);
    innerHTMLs = [];
  }  
}
  
)();

