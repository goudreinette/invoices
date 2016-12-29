require "prawn"
require "combine_pdf"

class Template
  def self.render_to_pdf(invoice)
    file = "Invoice #{invoice.no}.pdf"
    puts "Saving to '#{file}'..."

    Prawn::Font::AFM.hide_m17n_warning = true
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

  def self.text(pdf, text, options = {})
    x = -36 + options[:at][0]
    y = 805 - options[:at][1]

    options = options.merge({width: 200, height: 100, at: [x, y]})
    pdf.text_box text, options
  end

  def self.format_money(number)
    "€ %.2f" % number
  end
end

class DefaultTemplate < Template
  def self.path
    'default'
  end

  def self.render(invoice, pdf)
    pdf.font_size 9
    # Register font here

    # items
    invoice.items.keys.each_with_index do |item, index|
      text pdf, item,              			           at: [90, 360 + index * 56]
      text pdf, format_money(invoice.items[item]), at: [450, 360 + index * 56]
    end

    text pdf, invoice.to,                  					  at: [85, 121]
    text pdf, invoice.no,                  					  at: [168, 247], size: 12
    text pdf, invoice.date,                					  at: [85.5, 292]
    text pdf, invoice.reference,           					  at: [276, 292]
    text pdf, invoice.client,              					  at: [414, 292]
    text pdf, format_money(invoice.subtotal),         at: [90, 550]
    text pdf, format_money(invoice.btw),   	          at: [159, 550]
    text pdf, format_money(invoice.total),            at: [385, 538], size: 18
  end
end
