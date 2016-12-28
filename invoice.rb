require "prawn"

class Invoice
  def self.for_client(client, &block)
    invoice = self.new(client)
    invoice.instance_eval(&block)
    invoice
  end

  def initialize(client)
    now        = Time.now
    @no        = "##{now.year}#{now.month}#{now.day}"
    @date      = "#{now.day}-#{now.month}-#{now.year}"
    @client    = client
    @reference = '-'
    @items     = {}
    @address
    @postcode
    @city
  end

  def full_address
    "#{@address}, \n#{@postcode}, #{@city}"
  end

  def method_missing(method, value = nil)
    if value
      instance_variable_set "@#{method}", value
      value
    else
      instance_variable_get "@#{method}"
    end
  end

  def subtotal
    @items.values.inject(:+)
  end

  def btw
    subtotal * 0.21
  end

  def total
    subtotal + btw
  end

  def to
    "#{client},\n#{full_address}"
  end

  def format_money(number)
     "%.2f" % number
  end

  def and_then
    yield self
    self
  end

  def to_pdf
    file = "Invoice #{no}.pdf"
    puts "Saving to '#{file}'..."

    Prawn::Document.generate file do |pdf|
      pdf.font_size 9

      # items
      @items.keys.each_with_index do |item, index|
        pdf.text_box item,              width: 100, height: 100, at: [100, 400 - index * 50]
        pdf.text_box @items[item].to_s, width: 100, height: 100, at: [400, 400 - index * 50]
      end

      pdf.text_box to,                  width: 300, height: 100, at: [50, 600]
      pdf.text_box no,                  width: 300, height: 100, at: [200, 500], size: 12
      pdf.text_box date,                width: 300, height: 100, at: [100, 450]
      pdf.text_box reference,           width: 300, height: 100, at: [250, 450]
      pdf.text_box client,              width: 300, height: 100, at: [400, 450]
      pdf.text_box format_money(btw),   width: 100, height: 100, at: [100, 250]
      pdf.text_box format_money(total), width: 100, height: 100, at: [400, 250], size: 14
    end
  end

  def to_s
    "<Invoice #{no}, client: #{client}, total: #{total}>"
  end
end
