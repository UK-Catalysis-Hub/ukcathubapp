class ThemesController < ApplicationController
  before_action :set_theme, only: %i[show edit update destroy articles]
  before_action :authenticate_user!, except: [:index, :show, :phases, :summary, :articles, :overview]

  # GET /themes (HTML)
  # GET /themes.json                   (API list; optional ?phase=I|II|III|Other|1|2|3|0|<roman/label>)
  def index
    @themes = Theme.all

    respond_to do |format|
      format.html
      format.json do
        scope = Theme.all
        if params[:phase].present?
          phase_filter = phase_value_from_param(params[:phase])
          scope =
            if phase_filter == :other
              scope.where(phase: [0, nil, "0", ""])
            elsif phase_filter.nil?
              scope # ignore unrecognised value
            else
              scope.where(phase: phase_filter)
            end
        end

        render json: {
          data: scope.order(:name).map { |t|
            {
              id:           t.id,
              name:         t.name,
              phase:        phase_label(t.phase),
              lead:         (t.lead rescue nil),
              publications: t.articles.count
            }
          },
          meta: {
            phases: present_phase_labels
          }
        }
      end
    end
  end

  # GET /themes/:id (HTML)
  # GET /themes/:id.json               (API theme details)
  def show
    @articles = @theme.articles.paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          data: {
            id:           @theme.id,
            name:         @theme.name,
            phase:        phase_label(@theme.phase),
            lead:         (@theme.lead rescue nil),
            description:  (@theme.description rescue nil),
            publications: @theme.articles.count
          }
        }
      end
    end
  end

  # GET /themes/phases.json             (API – drives the tabs)
  # If routed under /api/v1, it's /api/v1/themes/phases
  def phases
    counts_by_label = Hash.new(0)
    Theme.group(:phase).count.each { |raw, c| counts_by_label[phase_label(raw)] += c }

    data = present_phase_labels.map { |lbl| { phase: lbl, themes: counts_by_label[lbl] || 0 } }
    render json: { data: data }
  end

  # GET /themes/summary.json            (API – donut/pie data)
  # Optional ?phase=I|II|III|Other|1|2|3|0|<roman/label>
  def summary
    scope = Theme.all
    if params[:phase].present?
      phase_filter = phase_value_from_param(params[:phase])
      scope =
        if phase_filter == :other
          scope.where(phase: [0, nil, "0", ""])
        elsif phase_filter.nil?
          scope
        else
          scope.where(phase: phase_filter)
        end
    end

    labels = []
    counts = []
    scope.order(:name).each do |t|
      labels << t.name
      counts << t.articles.count
    end

    render json: {
      data: { labels: labels, counts: counts, total: counts.sum },
      meta: { phase: (params[:phase].presence || 'All') }
    }
  end

  # GET /themes/:id/articles.json       (API – publications for a theme)
  # Optional: ?page=1&per_page=12&order=year_desc|year_asc|title_asc|title_desc
  def articles
    per_page = (params[:per_page].presence || 12).to_i
    page     = (params[:page].presence || 1).to_i

    ordered = @theme.articles.order(articles_order_clause(params[:order]))
    items   = ordered.paginate(page: page, per_page: per_page)

    render json: {
      data: items.map { |a|
        {
          id:              a.id,
          title:           a.title,
          doi:             a.doi,
          pub_year:        a.pub_year,
          container_title: a.container_title,
          publisher:       a.publisher,
          graphic_abstract: a.graphic_abstract
        }
      },
      meta: {
        theme:       { id: @theme.id, name: @theme.name, phase: phase_label(@theme.phase) },
        pagination:  { page: page, per_page: per_page, total: ordered.count },
        order:       (params[:order].presence || 'year_desc')
      }
    }
  end

  # NEW: one-shot combined response for ALL themes (summary + details by phase)
  # GET /themes/overview.json
  # If routed under /api/v1, it's /api/v1/themes/overview
  #
  # Response shape:
  # {
  #   "data": {
  #     "phases": ["III","II","I","Other"],
  #     "themes_by_phase": { "I":[{id,name,phase,lead,publications}, ...], ... },
  #     "summary_by_phase": { "I":{labels:[...],counts:[...],total:N}, ... }
  #   }
  # }
  def overview
    phases = present_phase_labels

    themes_by_phase   = {}
    summary_by_phase  = {}

    phases.each do |label|
      rel =
        if label == "Other"
          Theme.where(phase: [0, nil, "0", ""])
        elsif label.match?(/\A[IVXLCDM]+\z/)
          Theme.where(phase: deromanize(label))
        else
          # If you ever store string phases in DB, match them directly
          Theme.where(phase: label)
        end

      rows = rel.order(:name).map do |t|
        pubs = t.articles.count
        { id: t.id, name: t.name, phase: label, lead: (t.lead rescue nil), publications: pubs }
      end

      themes_by_phase[label] = rows
      summary_by_phase[label] = {
        labels: rows.map { |h| h[:name] },
        counts: rows.map { |h| h[:publications] },
        total:  rows.sum { |h| h[:publications] }
      }
    end

    render json: {
      data: {
        phases: phases,
        themes_by_phase: themes_by_phase,
        summary_by_phase: summary_by_phase
      }
    }
  end

  # ---------- CRUD (unchanged) ----------

  # GET /themes/new
  def new
    @theme = Theme.new
  end

  # GET /themes/1/edit
  def edit; end

  # POST /themes or /themes.json
  def create
    @theme = Theme.new(theme_params)

    respond_to do |format|
      if @theme.save
        format.html { redirect_to theme_url(@theme), notice: "Theme was successfully created." }
        format.json { render :show, status: :created, location: @theme }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /themes/1 or /themes/1.json
  def update
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to theme_url(@theme), notice: "Theme was successfully updated." }
        format.json { render :show, status: :ok, location: @theme }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1 or /themes/1.json
  def destroy
    @theme.destroy!

    respond_to do |format|
      format.html { redirect_to themes_url, notice: "Theme was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # download theme stats (CSV) – preserved
  def themes_count
    theme_pubs = ListTheme.where("NOT (id IN (6,11,14,15))")
                          .collect { |th| [th.name, th.article_count.to_i, th.phase.to_i] }
    theme_csv = get_csv(%w[name count phase], theme_pubs)
    send_data(
      theme_csv,
      type: 'text/plain',
      disposition: 'attachment',
      filename: 'ukch_theme_count.csv'
    )
  end

  private

    # Callbacks
    def set_theme
      @theme = Theme.find(params[:id])
    end

    # Strong params
    def theme_params
      params.require(:theme).permit(:short, :name, :lead, :phase, :used, :theme_type)
    end

    # -------- Phase / ordering helpers (data-driven, no hard-coded I/II/III) --------

    # Convert integers to Roman numerals (generic)
    def romanize(n)
      n = n.to_i
      return n.to_s if n <= 0
      map = {1000=>"M",900=>"CM",500=>"D",400=>"CD",100=>"C",90=>"XC",50=>"L",40=>"XL",10=>"X",9=>"IX",5=>"V",4=>"IV",1=>"I"}
      res = +""
      map.each do |k, sym|
        q, n = n.divmod(k)
        res << sym * q
      end
      res
    end

    # Parse Roman numerals back to integer (I, II, III, IV, …)
    def deromanize(s)
      r = { "M"=>1000, "CM"=>900, "D"=>500, "CD"=>400, "C"=>100, "XC"=>90, "L"=>50, "XL"=>40,
            "X"=>10, "IX"=>9, "V"=>5, "IV"=>4, "I"=>1 }
      up = s.to_s.upcase
      i = 0
      n = 0
      while i < up.length
        if i + 1 < up.length && r[up[i,2]]
          n += r[up[i,2]]
          i += 2
        else
          n += r[up[i]] || 0
          i += 1
        end
      end
      n
    end

    # Human-friendly label for whatever is stored in DB
    def phase_label(raw)
      return "Other" if raw.nil? || raw.to_s.strip == "" || raw.to_s == "0"
      return romanize(raw.to_i) if raw.to_s.match?(/\A\d+\z/)
      raw.to_s
    end

    # Interpret incoming ?phase=... filter: integer, roman, or "Other"
    def phase_value_from_param(param)
      v = param.to_s.strip
      return :other if v.casecmp("Other").zero? || v == "0"
      return v.to_i  if v.match?(/\A\d+\z/)
      n = deromanize(v)
      n > 0 ? n : nil
    end

    # Compute present phase labels dynamically and order them
    # Numeric (roman) phases in descending numeric order, "Other" at the end, other labels preserved.
    def present_phase_labels
      raw_values = Theme.distinct.pluck(:phase)
      labels = raw_values.map { |x| phase_label(x) }.uniq

      romans  = labels.grep(/\A[IVXLCDM]+\z/).sort_by { |r| -deromanize(r) }
      others  = labels - romans
      # Put "Other" at the end if present
      others = (others - ["Other"]) + (others.include?("Other") ? ["Other"] : [])
      romans + others
    end

    # Whitelist sort options for theme articles
    def articles_order_clause(param)
      case param
      when 'year_asc'   then { pub_year: :asc,  id: :asc }
      when 'title_asc'  then { title:    :asc }
      when 'title_desc' then { title:    :desc }
      else                   { pub_year: :desc, id: :desc } # default 'year_desc'
      end
    end
end
