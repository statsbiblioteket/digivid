<%@ page import="dk.statsbiblioteket.deck.client.webinterface.ControlServlet" %>
<%@ page import="dk.statsbiblioteket.deck.client.webinterface.WebConstants" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%
    request.setCharacterEncoding("UTF-8");
    String encoderName = request.getParameter(WebConstants.ENCODER_NAME_PARAM);
    //The cards actually available as determined
    //by querying the encoder
    Pattern pattern = Pattern.compile(".*/dev/video([0-9]).*");
    List<String> jobs = ControlServlet.runUnixCommand(encoderName, "ps -C cat -o args", 0, 1);
    Set<Integer> used_cards = new HashSet<Integer>();
    for (String job : jobs) {
        Matcher m = pattern.matcher(job);
        boolean matchb = m.matches();
        if (matchb) {
            used_cards.add(Integer.parseInt(m.group(1)));
        }
    }
    Set<Integer> available_cards_s = new HashSet<Integer>();
    int[] all_cards = new int[]{0, 2};
    for (int card : all_cards) {
        if (!used_cards.contains(new Integer(card))) {
            available_cards_s.add(card);
        }
    }
    Integer[] available_cards = available_cards_s.toArray(new Integer[available_cards_s.size()]);
    Arrays.sort(available_cards);
    String[] source_names = new String[available_cards.length];
    for (int i = 0; i < available_cards.length; i++) {
        int card = available_cards[i].intValue();
        if (card == 0) source_names[i] = "Source A";
        if (card == 2) source_names[i] = "Source B";
    }
%>
Recording on <%=encoderName%>
<form action="Control" method="post">
    <%
        if (available_cards.length == 0) {
    %>
    All cards currently recording
    <%
        return;
    } else if (available_cards.length == 1) {
    %>
    <div class="field">
        <label for="singleCard"><%=source_names[0]%></label>
        <input type="radio" id="singleCard" name="<%=WebConstants.CARD_NAME_PARAM%>" value="<%=available_cards[0].intValue()%>" checked="true"/>
    </div>
    <%
    } else {
        for (int i = 0; i < available_cards.length; i++) {
    %>
    <div class="field">
        <label for="<%=available_cards[i]%>"><%=source_names[i]%></label>
        <input type="radio" id="<%=available_cards[i]%>" name="<%=WebConstants.CARD_NAME_PARAM%>"
               value="<%=available_cards[i]%>"/>
    </div>
    <%
            }
        }
    %>

    <div class="field">
        <label for="file_name_param">Extra filename component:</label>
        <input type="text" id="file_name_param" name="<%=WebConstants.FILE_NAME_PARAM%>">
    </div>

    <div class="field">
        <label for="channel_label_param">Original channel: </label>
        <select id="channel_label_param" name="<%=WebConstants.CHANNEL_LABEL_PARAM%>">
            <option value="K11-DR1">DR1</option>
            <option value="K9-DR2">DR2</option>
            <option value="K10-TV2-Danmark">TV2-Danmark</option>
            <option value="K67-TV2-Zulu">TV2-Zulu</option>
            <option value="K40-TV2-Charlie">TV2-Charlie</option>
            <option value="S14-TV-Danmark">TV-Danmark</option>
            <option value="K54-Kanal5">Kanal5</option>
            <option value="K63-DK4">DK4</option>
            <option value="K67-TV2-Zulu">TV2-Zulu</option>
            <option value="TV-Sport">TV-Sport</option>
        </select>
    </div>


    <div class="field">
        <label for="start_time_field">Original Start Date-Time:</label>
        <input type="text" id="start_time_field" readonly="true" name="<%=WebConstants.START_TIME_PARAM%>"/>
    </div>

    <div class="field">
        <label for="mpeg1">MPEG-1:</label>
        <input type="radio" id="mpeg1" name="<%=WebConstants.CAPTURE_FORMAT_PARAM%>" value="mpeg1" checked="checked"/>
    </div>
    <div class="field">
        <label for="mpeg2">MPEG-2:</label>
        <input type="radio" id="mpeg2" name="<%=WebConstants.CAPTURE_FORMAT_PARAM%>" value="mpeg2"/><br/>
    </div>

    <div class="field">
        <label for="recording_time_param">Recording Time (minutes):</label>
        <input id="recording_time_param" size="5" name="<%=WebConstants.RECORDING_TIME_PARAM%>" value="60"/><br/>
    </div>

    <div class="field">
        <label for="vhs_label">VHS Label:</label>
        <textarea id="vhs_label" name="<%=WebConstants.VHS_LABEL_PARAM%>" class="input" rows="3" cols="100"></textarea>
    </div>

    <input type="hidden" name="<%=WebConstants.CONTROL_COMMAND_PARAM%>" value="<%=WebConstants.START_RECORDING%>"/>
    <input type="hidden" name="<%=WebConstants.USER_NAME_PARAM%>" value="digivid"/>
    <input type="hidden" name="<%=WebConstants.INPUT_CHANNEL_ID_PARAM%>" value="SB-Tape1"/>
    <input type="hidden" name="<%=WebConstants.ENCODER_NAME_PARAM%>" value="<%=encoderName%>"/>

    <input type="submit" name="start" value="start"/>
</form>

<script type="text/javascript">
    Calendar.setup({
        inputField: "start_time_field",      // id of the input field
        ifFormat: "<%=WebConstants.jscalendar_format_string%>",
        showsTime: true,            // will display a time selector
        singleClick: true,           // double-click mode
        step: 1,                // show all years in drop-down boxes (instead of every other year as default)
        firstDay: 1
    });
</script>