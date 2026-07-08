#!/bin/bash
# Mindset Mastery / ColhounTech BBB customizations
# Canonical copy — deployed to /etc/bigbluebutton/bbb-conf/apply-config.sh
# See CUSTOMIZATIONS.md for what each setting does.

source /etc/bigbluebutton/bbb-conf/apply-lib.sh

enableUFWRules

PRESENTATION_PDF=/root/Mindset.Mastery.Presentation.pdf
cp "$PRESENTATION_PDF" /usr/share/bigbluebutton/blank/blank-presentation.pdf
cp "$PRESENTATION_PDF" /var/bigbluebutton/blank/blank-presentation.pdf
cp "$PRESENTATION_PDF" /var/www/bigbluebutton-default/default.pdf
cp "$PRESENTATION_PDF" /var/www/bigbluebutton-default/assets/default.pdf

cp /etc/bigbluebutton/bbb-conf/index.html /var/www/bigbluebutton-default/assets/index.html

yq eval -i '.public.layout.hidePresentationOnJoin = true' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.layout.showSessionDetailsOnJoin = false' /etc/bigbluebutton/bbb-html5.yml

yq eval -i '.public.app.userSettingsStorage = "local"' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.app.skipCheck = true' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.app.skipCheckOnJoin = true' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.app.skipEchoTestIfPreviousDevice = true' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.app.listenOnlyMode = false' /etc/bigbluebutton/bbb-html5.yml

# Video: do NOT set skipVideoPreview or skipVideoPreviewOnFirstJoin to true —
# that breaks manual webcam sharing ("Finding webcams" hangs forever).
yq eval -i '.public.kurento.skipVideoPreview = false' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.kurento.skipVideoPreviewOnFirstJoin = false' /etc/bigbluebutton/bbb-html5.yml
yq eval -i '.public.kurento.skipVideoPreviewIfPreviousDevice = true' /etc/bigbluebutton/bbb-html5.yml

yq eval -i '.public.notes.enabled = false' /etc/bigbluebutton/bbb-html5.yml

if grep -q "^defaultWelcomeMessageFooter=" /etc/bigbluebutton/bbb-web.properties 2>/dev/null; then
  sed -i "s/^defaultWelcomeMessageFooter=.*/defaultWelcomeMessageFooter=/" /etc/bigbluebutton/bbb-web.properties
else
  echo "defaultWelcomeMessageFooter=" >> /etc/bigbluebutton/bbb-web.properties
fi

if grep -q "^disabledFeatures=" /etc/bigbluebutton/bbb-web.properties 2>/dev/null; then
  sed -i "s/^disabledFeatures=.*/disabledFeatures=sharedNotes/" /etc/bigbluebutton/bbb-web.properties
else
  echo "disabledFeatures=sharedNotes" >> /etc/bigbluebutton/bbb-web.properties
fi