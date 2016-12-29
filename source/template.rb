require "prawn"
require "combine_pdf"

class Template
  def self.render_to_pdf(invoice)
    file = "Invoice #{invoice.no}.pdf"
    puts "Saving to '#{file}'..."

    Prawn::Document.generate file do |pdf|
      render(invoice, pdf)
    end

    combine(file)
  end

  def self.combine(file)
    template = CombinePDF.load("templates/#{path}.pdf")
    rendered = CombinePDF.load(file)

    template.pages.zip(rendered.pages) do |t, r|
      t << r
    end

    template.save file
  end
end

class DefaultTemplate < Template
  def self.path
    'default'
  end

  def self.render(invoice, pdf)
    pdf.font_size 9

    # items
    invoice.items.keys.each_with_index do |item, index|
      pdf.text_box item,              			 width: 100, height: 100, at: [100, 400 - index * 50]
      pdf.text_box invoice.items[item].to_s, width: 100, height: 100, at: [400, 400 - index * 50]
    end

    pdf.text_box invoice.to,                  					 width: 300, height: 100, at: [50, 600]
    pdf.text_box invoice.no,                  					 width: 300, height: 100, at: [200, 500], size: 12
    pdf.text_box invoice.date,                					 width: 300, height: 100, at: [100, 450]
    pdf.text_box invoice.reference,           					 width: 300, height: 100, at: [250, 450]
    pdf.text_box invoice.client,              					 width: 300, height: 100, at: [400, 450]
    pdf.text_box invoice.format_money(invoice.btw),   	 width: 100, height: 100, at: [150, 250]
    pdf.text_box invoice.format_money(invoice.subtotal), width: 100, height: 100, at: [100, 250]
    pdf.text_box invoice.format_money(invoice.total),  	 width: 100, height: 100, at: [360, 250], size: 18
  end
end
