Raw data come from 

1. InterBrand (12/15/21)
This data was scraped from https://www.rankingthebrands.com/. The data contains the brand values, the brand ranks, brand names and year for the years 2007-2020. It first gets the driver of the website. It opens a new Google Chrome page. Afterwards, using the command "driver.find_elements_by_class_name", the data is scrapped. The class name for each data variable e.g. the brand name is found by right clicking on the webpage that is opened by Google Chrome and clicking on "Inspect". After some research, the class name for each variable can be found. You can find the class name quickly by clicking on the select symbol and putting your cursor on the thing you want to scrape. Since the scrapped data is not in text format, we need to convert them into text. This is why there is a written loop to convert and append all scrapped data. In the end, the lists of data are converted to a dataframe containing all. Since after scraping, it is realized that 100th brand is not included. They are appended to the dataframe with a code manually. The dataframe is converted to an excel file. In the end, the same procedure is done for every year.

After all, the all Excel Files are appended to each other and the final Excel file is named "Brands_2007-2020_RankingTheBrands.xlsx". Also, the excel files that will not be used are deleted through the code.

2. BrandFinance (12/15/21)
In the second part of the code, from https://brandirectory.com/, the data files containing brand names, ranks and company values are downloaded manually. In this file, they are appended to each other with a code.

3. Manual Verification
In the ManualVerification.xlsx file, it can be seen that for every year, 5 brands are selected by random by hand. Then, they are verified from the website.

4. Manual Work
Cross walk 

5. National Accounts Data (12/22/21)
Source: https://unstats.un.org/unsd/snaama/Basic
Downloaded file: ValueAddedConstantPricesUSD.xlsx

6. Eurostat Data (1/4/22)
Source: https://appsso.eurostat.ec.europa.eu/nui/show.do?dataset=nama_10_a64_e&lang=en
Downloaded file: EuroStatEmployment.xlsx

7. BLS Employment data (1/4/22)
Source: https://www.bls.gov/iag/tgs/iag42.htm
Downloaded file: BureauLaborStats.xlsx (also note headers in sheets for additional information)




