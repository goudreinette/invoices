require "./source/invoice.rb"



Invoice.new_for_client 'Hans van der Woerd' do
  address  "Korte Smeden 8g"
  postcode "8011VC"
  city     "Zwolle"
end.to_pdf
