require_relative "template"

class Invoice
  def self.new_for_client(client, &block)
    invoice = self.new(client)
    invoice.instance_eval(&block)
    invoice
  end

  def initialize(client)
    now        = Time.now
    @no        = "##{now.year}#{now.strftime("%m")}#{now.strftime("%d")}"
    @date      = "#{now.strftime("%d")}-#{now.strftime("%m")}-#{now.year}"
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
    @items.values.inject 0, :+
  end

  def tax
    subtotal * 0.21
  end

  def total
    subtotal + tax
  end

  def to
    "#{client},\n#{full_address}"
  end

  def and_then
    yield self
    self
  end

  def to_s
    "<Invoice #{no}, client: #{client}, total: #{total}>"
  end

  def to_pdf(template = DefaultTemplate)
    template.render_to_pdf(self)
  end
end
