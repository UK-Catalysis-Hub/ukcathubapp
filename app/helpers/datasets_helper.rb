module DatasetsHelper
  def get_do_yearly_counts
    year_series = []
    do_by_year = Dataset.ds_per_year
    doby = do_by_year.each.collect{ |doby| [doby['item'], doby['i_count']]}
    year_series[0] = {name:"per year", data: doby}
    sum = 0
    year_series[1] = {name:"accumulated", data: doby.each.collect{ |aby| [aby[0], sum+=aby[1]] } } 
    year_series
  end
end
