.PHONY: clean upload_aws invoke log_aws aws

.SECONDARY:

dests = aws

aws_fn := $(aws_fn)

tg_musl = x86_64-unknown-linux-musl
rl_dir = target/$(tg_musl)/release

dist = dist
aws_out := $(dist)/aws_out
aws_log := $(dist)/aws_log
aws_event := $(dist)/aws_event.json

$(rl_dir)/%: src/*.rs src/bin/*.rs
	cargo build --release --bin $(@F) --target $(tg_musl)

$(dist)/%/bootstrap: $(rl_dir)/%_entry
	mkdir -p $(@D)
	cp $< $@

$(dist)/%/app.zip: $(dist)/%/bootstrap
	zip -j $@ $<

$(dests): %: $(dist)/%/app.zip

upload_aws: $(dist)/aws/app.zip
	aws lambda update-function-code --function-name $(aws_fn) --zip-file fileb://$<

invoke_aws:
	aws lambda invoke --function-name $(aws_fn) $(aws_out) \
	--output text --payload fileb://$(aws_event) \
	--log-type Tail > $(aws_log)

log_aws:
	grep -oE '\S{20,}' $(aws_log)| base64 -d
	cat $(aws_out)

clean:
	cargo clean
	rm -rf dist/*
