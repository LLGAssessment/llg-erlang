ERL=erl
ERLC=erlc
TIME=time

llg.beam: llg.erl
	$(ERLC) "$<"
run: llg.beam
	$(ERL) -s llg main -s init stop -noshell
bench:
	$(TIME) $(ERL) -s llg main -s init stop -noshell
clean:
	rm llg.beam
