class Recepcion::PatientsController < Recepcion::ApplicationController
  before_action :authenticate_user!

  def index
    @patients = Patient.all.order(created_at: -1).limit(20)
    @patients = Patient.search(params[:search][:nombre]) if params[:search].present?
  end

  def show
    @patient = Patient.find(params[:id])
    authorize @patient

    @patient_notes = @patient.all_history
  end

  def new
    @patient = Patient.new

    authorize @patient
  end

  def create
    @patient = Patient.new(patient_params)
    authorize @patient

    if @patient.save
      @patient.space.update(assigned_patient: @patient) if @patient.space.present?
      @patient.create_default_notes
      redirect_to recepcion_patients_path, notice: "Paciente: <b>#{patient_params[:nombre]}</b> se ha agregado <b>correctamente</b>"
    else
      flash.now[:notice] = 'Por favor, verifica que hayas introducido toda la información correspondiente al paciente'
      render :new
    end
  end

  def edit
    @patient = Patient.find(params[:id])

    authorize @patient
  end

  def update
    @patient = Patient.find(params[:id])
    authorize @patient

    if @patient.update(patient_params)
      if @patient.space.present?
        @patient.space.update(assigned_patient: @patient)
      else
        PatientSpace.where(assigned_patient: @patient).update_all(assigned_patient: nil)
      end
      redirect_to recepcion_patient_path(@patient), notice: "Paciente: <b>#{patient_params[:nombre]}</b> se ha actualizado <b>correctamente</b>"
    else
      flash.now[:notice] = 'Por favor, verifica que hayas introducido toda la información correspondiente al paciente'
      render :new
    end
  end

  def especialistas
    @especialistas ||= User.especialistas
  end
  helper_method :especialistas

  def patient_spaces
    @patient_spaces ||= PatientSpace.where(assigned_patient: { '$in': [@patient.id, nil] })
  end
  helper_method :patient_spaces

  private

  def patient_params
    params.require(:patient).permit(
      :nombre,
      :sexo,
      :fecha_de_nacimiento,
      :edad,
      :tipo_paciente,
      :direccion_del_paciente,
      :ciudad_del_paciente,
      :familiar_responsable,
      :celular_del_responsable,
      :direccion_del_responsable,
      :ciudad_del_responsable,
      :space_id,
      :estado_del_paciente,
      :visitas,
      especialista_ids: []
    )
  end
end
