const puppeteer = require('puppeteer');
const fs = require('fs');

// const base_URL = `https://corp.sec.state.ma.us/corpweb/CorpSearch/CorpSearch.aspx`;
const base_URL = `https://dlsgateway.dor.state.ma.us/gateway/DLSPublic/CorpBookSearch`;
const search_str = ' ';
const start_pg = 0;
//const year = 2003;
const years = [...Array(18)].map((_, i) => 2003 + i);

(async () => {
    const browser = await puppeteer.launch({
        headless: false,
        args: ['--window-size=1920,1040'],
        slowMo: 1//100
    });
    const page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1040 });
    await page.goto(base_URL);

    for (var i = 0; i < years.length; i++) {
        let year = years[i];

        let save_dir = year.toString();
        if (!fs.existsSync(save_dir)) fs.mkdirSync(save_dir);

        await page.waitForSelector('#FiscalYear');
        await page.select('#FiscalYear', year.toString());
        await page.click('#Go');

        await page.waitForTimeout(1000);
        await page.waitForSelector('#txtFirstTerm');
        await page.$eval('#txtFirstTerm', (el, s) => el.value = s, search_str);
        await page.click('#chkClass-c');
        await page.click('#btnSearch');

        await page.waitForTimeout(1000);
        await page.waitForSelector('#tblCorpBookData_wrapper');
        await page.select('select[name="tblCorpBookData_length"]', '100');

        let count = 1;
        while (true) {
            try {
                await page.waitForTimeout(1000);
                await page.waitForSelector('#tblCorpBookData_next');
                await page.click('#btnSearch');
                await page.waitForSelector('#tblCorpBookData_next');

                save_file = save_dir + '/' + count.toString() + '.html';//'+Date.now().toString()+'.JSON';
                let html = await page.content();
                fs.writeFileSync(save_file, html);

                console.log(count);
                count += 1;
            } catch (error) {
                console.error(error);
            }
        }
    }   
}
)();
