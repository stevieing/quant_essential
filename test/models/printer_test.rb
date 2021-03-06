# frozen_string_literal: true

require 'test_helper'

class PrinterTest < ActiveSupport::TestCase
  include WithStubbedPmb
  test '::external_printers returns a list of pmb registered printers' do
    PMB::TestSuiteStubs.get('/v1/printers') { |_env| [200, { content_type: 'application/json' }, printers_index] }
    assert_equal %w[printer_a printer_b], Printer.external_printers
  end

  test '#exists_externally? returns true if the printer exists in PMB' do
    PMB::TestSuiteStubs.get('/v1/printers') { |_env| [200, { content_type: 'application/json' }, printers_index] }
    printer = create :printer, name: 'printer_a'
    assert printer.exists_externally?
  end

  test '#exists_externally? returns false if the printer exists in PMB' do
    PMB::TestSuiteStubs.get('/v1/printers') { |_env| [200, { content_type: 'application/json' }, printers_index] }
    printer = create :printer, name: 'unknown_printer'
    assert !printer.exists_externally?
  end
end
