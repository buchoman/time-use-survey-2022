# Time Use Survey 2022 - Time Estimates Application

This application allows users to select demographic attributes and get detailed estimates of average time spent on activities from the Time Use Survey 2022, with bootstrap variance estimates.

## Features

- **Interactive Filtering**: Select attributes including:
  - Geography (Province, Region)
  - Demographics (Gender, Age, Marital Status)
  - Employment Status
  - Number and Age of Children
  - Spousal/Partner Employment Status
  - Additional characteristics (Education, Income, etc.)

- **Comprehensive Time Estimates**: 
  - Estimates for all activity codes (DUR variables)
  - Aggregated estimates by activity category
  - All estimates in minutes per day

- **Bootstrap Variance Estimation**:
  - Uses all 500 bootstrap weights (WTBS_001 to WTBS_500) for proper variance estimation
  - Provides standard errors and coefficients of variation

- **Export Options**:
  - CSV export for activity codes
  - CSV export for aggregated categories
  - Excel export with both sheets

## Installation

1. Install Python 3.8 or higher

2. Install required packages:
```bash
pip install -r requirements.txt
```

## Usage

1. Ensure the data files are in the correct location:
   - `TU_ET_2022/Data_Données/TU_ET_2022_Main-Principal_PUMF.sas7bdat`

2. Run the Streamlit application:
```bash
streamlit run app.py
```

3. The application will open in your web browser. Use the sidebar to:
   - Select demographic attributes
   - Click "Apply Filters"
   - Click "Calculate Estimates"
   - Download results as CSV or Excel

## Data Requirements

The application requires the Time Use Survey 2022 Main dataset in SAS format (.sas7bdat). The dataset should include:
- All DUR variables (activity duration variables)
- Demographic variables (PRV, REGION, GENDER2, etc.)
- Bootstrap weights (WTBS_001 to WTBS_500)
- Person weight (WGHT_PER)

## Bootstrap Variance Methodology

The bootstrap variance is calculated using the standard Statistics Canada methodology:

1. Calculate the estimate using the main person weight (WGHT_PER)
2. Calculate estimates using each of the 500 bootstrap weights (WTBS_001 to WTBS_500)
3. Calculate variance as: `Variance = mean((estimate_b - estimate_full)^2)` where b ranges over all bootstrap replicates

This provides proper variance estimates that account for the complex survey design.

## Activity Categories

Activities are organized into the following categories:
- Sleep and Rest
- Personal Care
- Eating and Drinking
- Household Work
- Shopping
- Childcare
- Adult Care
- Travel
- Paid Work
- Education
- Socializing
- Volunteering and Unpaid Work
- Civic and Religious
- Sports and Exercise
- Culture and Leisure
- Mass Media
- Other Activities

## Notes

- Calculations may take a few minutes when processing all activities with bootstrap variance
- The application uses caching to speed up data loading
- Ensure sufficient memory for large datasets

