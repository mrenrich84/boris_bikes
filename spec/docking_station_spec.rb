require 'docking_station'
require 'bike'
require 'pry'
require 'pry-byebug'
require 'support/shared_examples_for_bike_container'


describe DockingStation do

  it_behaves_like BikeContainer


  it { is_expected.to respond_to(:release_bike) }
  it { is_expected.to respond_to(:bikes)}
  it { is_expected.to respond_to(:dock).with(1).argument}


  describe "#initialize(capacity = DEFAULT)" do
    context "when creating a new object" do
      it "object can be created without parameters" do
        expect(DockingStation.new.class).to eq(DockingStation)
      end
      it "object can be created with a given capacity on first parameter" do
        expect(DockingStation.new(35).class).to eq(DockingStation)
      end
    end
  end

  describe "#bikes" do
    before do
      @bike1 = Bike.new
      @bike2 = Bike.new
      subject.dock(@bike1)
      subject.dock(@bike2)
    end

    it 'returns the array of docked Bike objects' do
      expect(subject.bikes).to eq([@bike1, @bike2])
    end
  end

  describe "#release_bike" do
    context 'when DockingStation is empty' do
      it 'does not release a Bike object if dock is empty' do
        expect {subject.release_bike}.to raise_error("No bikes available")
      end
    end

    context 'when DockingStation has 1 bike' do
      before do
        # let(:bike) { double :bike }
        @bike = double(:bike)
        binding.pry
        subject.dock(@bike)
        allow(@bike).to receive(:broken?).and_return(false)
      end

      it 'releases a Bike object' do
        expect(subject.release_bike).to eq @bike
      end
      it 'is returning a Bike object which is working' do
        expect(subject.release_bike.broken?).to eq false
      end
      context "and bike is broken" do
        before do
          allow(@bike).to receive(:report_broken)
          subject.bikes[0].report_broken
          allow(@bike).to receive(:broken?).and_return(true)
        end
        it "raises a No bikes available error" do
          expect {subject.release_bike}.to raise_error("No bikes available")
        end
      end
    end

    context "when DockingStation has 2+ bikes" do
      before do
        @bike1 = Bike.new
        @bike2 = Bike.new
        @bike3 = Bike.new
        subject.dock(@bike1)
        subject.dock(@bike2)
        subject.dock(@bike3)
      end
      context "and 1+ bike is broken" do
        before do
          subject.bikes[1].report_broken
        end
        it 'is returning a Bike object which is working' do
          expect(subject.release_bike.broken?).to eq false
        end
        it 'and all the other bikes are docked and in place into the array' do
          subject.release_bike         
          expect(subject.bikes).to eq([@bike1,@bike2])
        end
      end
    end
  end

  describe "#dock(bike)" do
    before do
      @bike = Bike.new
    end

    context 'when DockingStation is not full' do
      it 'can dock a Bike object' do
        expect(subject.dock(@bike)).to eq [@bike]
      end
    end

    context 'when docking station is full' do
      before do
        DockingStation::DEFAULT_CAPACITY.times { subject.dock(Bike.new) }
      end
      it 'raises an error' do
        expect {subject.dock(Bike.new)}.to raise_error("DockingStation full")
      end
    end

    context "when a docking station object is created with a given capacity"  do
      before do
        @capacity = 5
        @obj_with_capacity = DockingStation.new(@capacity)
        @capacity.times { @obj_with_capacity.dock(Bike.new) }
      end
      it "will not let dock more bike than capacity" do
        expect {@obj_with_capacity.dock(Bike.new)}.to raise_error("DockingStation full")
      end
    end

  end



end
