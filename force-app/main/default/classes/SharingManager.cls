public interface SharingManager {
    String execute(String buttonName, String paramsString);
    List<ListBuilderController.ShareInfo> getExisting(String recordId);
    List<ListBuilderController.ButtonSetting> getSupportedButtons();
}