class Patient < ApplicationRecord
  include Mongoid::Document
  include Mongoid::Timestamps

  before_save :set_unique_especialista_ids

  field :nombre, type: String
  field :fecha_de_nacimiento, type: Date
  field :edad, type: Integer
  field :direccion_del_paciente, type: String
  field :ciudad_del_paciente, type: String
  field :familiar_responsable, type: String
  field :celular_del_responsable, type: String
  field :direccion_del_responsable, type: String
  field :ciudad_del_responsable, type: String
  field :estado_del_paciente, type: String
  field :sexo, type: String
  field :visitas, type: String
  field :tipo_paciente, type: String
  field :especialista_ids, type: Array

  embeds_one :historia_clinica_note
  embeds_many :urgencias_notes
  embeds_many :evolucion_notes
  embeds_many :traslado_notes
  embeds_many :interconsulta_notes
  embeds_many :pre_operatoria_notes
  embeds_many :pre_anestesica_notes
  embeds_many :post_operatoria_notes
  embeds_many :post_anestesica_notes
  embeds_many :egreso_notes
  embeds_one :enfermeria_sheet
  embeds_many :servicios_auxiliares_sheets
  embeds_many :transfusion_sheets
  embeds_one :trabajo_social_sheet
  embeds_many :consentimiento_informado_sheet
  embeds_one :egreso_voluntario_sheet
  embeds_one :ministerio_publico_sheet
  embeds_one :defuncion_note
  embeds_many :analisis_clinico_notes
  embeds_many :medica_notes
  embeds_one :pertenencias_note
  embeds_many :medicine_lists

  belongs_to :user, optional: true
  belongs_to :space, class_name: 'PatientSpace', optional: true

  validates :nombre, presence: true
  validates :sexo, presence: true
  validates :fecha_de_nacimiento, presence: true
  validates :edad, presence: true
  validates :tipo_paciente, presence: true
  validates :direccion_del_paciente, presence: true
  validates :ciudad_del_paciente, presence: true
  validates :familiar_responsable, presence: true
  validates :celular_del_responsable, presence: true, length: { is: 10 }
  validates :direccion_del_responsable, presence: true
  validates :ciudad_del_responsable, presence: true
  validates :sexo, presence: true
  validates :especialista_ids, presence: true

  accepts_nested_attributes_for(
    :historia_clinica_note,
    :urgencias_notes,
    :evolucion_notes,
    :traslado_notes,
    :interconsulta_notes,
    :pre_operatoria_notes,
    :pre_anestesica_notes,
    :post_operatoria_notes,
    :post_anestesica_notes,
    :egreso_notes,
    :enfermeria_sheet,
    :servicios_auxiliares_sheets,
    :transfusion_sheets,
    :trabajo_social_sheet,
    :consentimiento_informado_sheet,
    :egreso_voluntario_sheet,
    :ministerio_publico_sheet,
    :defuncion_note,
    :analisis_clinico_notes
  )

  def self.search(query_search)
    if query_search.blank?
      order(created_at: -1)
    else
      where({nombre: /.*#{query_search}.*/i })
    end
  end

  def especialistas
    @especialistas ||= User.where(id: { '$in': Array(especialista_ids) })
  end

  def create_default_notes
    self.historia_clinica_note = HistoriaClinicaNote.new_and_build_defaults
    self.build_pertenencias_note
    self.save
  end

  def all_history
    %i[
      historia_clinica_note
      urgencias_notes
      evolucion_notes
      traslado_notes
      interconsulta_notes
      pre_operatoria_notes
      pre_anestesica_notes
      post_operatoria_notes
      post_anestesica_notes
      egreso_notes
      enfermeria_sheet
      servicios_auxiliares_sheets
      transfusion_sheets
      trabajo_social_sheet
      consentimiento_informado_sheet
      egreso_voluntario_sheet
      ministerio_publico_sheet
      defuncion_note
      analisis_clinico_notes
    ].map{ |note| send(note).to_a }.flatten.compact.sort do |a, b|
      next 0 if a.created_at.blank? && b.created_at.blank?
      next -1 if a.created_at.blank?
      next 1 if b.created_at.blank?

      a.created_at <=> b.created_at
    end
  end

  private

  def set_unique_especialista_ids
    self.especialista_ids = Array(especialista_ids).uniq
  end
end
