
require "csv"

csv_data = CSV.read('db/sample20200712.csv', headers: true)
csv_data.each do |row|
  User.create(:name => row[0],
              :email => row[1],
              :affiliation => row[2],
              :employee_number => row[3],
              :uid => row[4],
              :basic_work_time => row[5],
              :designated_work_start_time => row[6],
              :designated_work_end_time => row[7],
              :superior => row[8],
              :admin => row[9],
              :password => row[10]
              )
end