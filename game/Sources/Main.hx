// Auto-generated
package ;
class Main {
    public static inline var projectName = 'BESTGAME';
    public static inline var projectVersion = '1.0.1';
    public static inline var projectPackage = 'arm';
    public static function main() {
        iron.object.BoneAnimation.skinMaxBones = 55;
            iron.object.LightObject.cascadeCount = 4;
            iron.object.LightObject.cascadeSplitFactor = 0.800000011920929;
        armory.system.Starter.main(
            'Scene',
            0,
            false,
            true,
            false,
            600,
            600,
            1,
            true,
            armory.renderpath.RenderPathCreator.get
        );
    }
}
